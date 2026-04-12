# Star Bionic — Splash Screen Integration Report
### Branded First-Launch Screen · Permission Flow Redesign · Auto-Rotation

**Prepared by:** The412Banner / BannerHub Team  
**Date:** 2026-04-12 (device verified)  
**APK analysed:** `star-Bionic_original.apk`  
**Integration repo:** https://github.com/The412Banner/star-test  
**Stable release:** https://github.com/The412Banner/star-test/releases/tag/v1.0.1  

---

## Implementation Status

| Job | Task | Status |
|---|---|---|
| 1 | Full-screen branded layout (`download_progress_dialog.xml`) | ✅ |
| 1 | App logo, title, version, subtitle, horizontal progress bar | ✅ |
| 1 | Light gray progress bar (`progressTint="#CCCCCC"`) | ✅ |
| 1 | ScrollView wrapper for landscape rotation support | ✅ |
| 2 | `DownloadProgressDialog.smali` — full-screen window setup | ✅ |
| 2 | `DownloadProgressDialog.smali` — `setProgress()` → ProgressBar cast | ✅ |
| 2 | `DownloadProgressDialog.smali` — `showPermissionsButton()` added | ✅ |
| 2 | `DownloadProgressDialog.smali` — `screenOrientation=SENSOR` on window | ✅ |
| 3 | `Lambda0` patched — calls `showPermissionsButton()` instead of `close()` | ✅ |
| 3 | `Lambda2` created — Runnable: `close()` + `doPermissionsFlow()` | ✅ |
| 4 | `MainActivity.smali` — `onCreate()` permission block removed | ✅ |
| 4 | `MainActivity.smali` — `doPermissionsFlow()` method added | ✅ |
| 5 | CI workflow — `smali_classes10` + layout patch copy steps added | ✅ |
| 5 | Stable `v1.0.1` released | ✅ https://github.com/The412Banner/star-test/releases/tag/v1.0.1 |

---

## Executive Summary

On first launch, the original Star Bionic immediately showed the system permissions dialog before any app UI was visible. The `DownloadProgressDialog` — a small circular progress indicator — was only shown *after* permissions were granted and installation started, meaning the branded app experience never appeared on first run.

This integration replaces that flow entirely:

- **Splash shows first** — `installIfNeeded()` is called immediately in `onCreate()` before any permission check, so the full-screen branded screen appears instantly on launch
- **Full-screen branded design** — dark background, app logo, "Winlator Star Bionic" title, "Bionic V1.0" version, "First launch setup" subtitle, horizontal progress bar tracking the installation
- **Permissions moved to a button** — when installation finishes, an "All Files Access Required" button replaces the auto-dismiss; the user must tap it to trigger the permission flow
- **Auto-rotation** — `screenOrientation=SCREEN_ORIENTATION_SENSOR` set on the dialog window, `ScrollView` wrapper for landscape content fit

The implementation required **4 smali patches**, **2 new smali classes**, **1 layout replacement**, and **2 CI workflow additions**. No new DEX slot is needed — all changes are within existing patched files (`smali_classes8`, `smali_classes10`) and the `res/layout` directory.

---

## 1. Feature Overview

### Before (original first-launch flow)

```
App opens
    ↓ onCreate()
    requestAppPermissions() → system permission dialog appears immediately
    ↓ user grants READ/WRITE storage
    onRequestPermissionsResult()
    ↓ ImageFsInstaller.installIfNeeded()
    DownloadProgressDialog (small circular spinner, dialog-sized)
        "Downloading File..." + circular % indicator
    ↓ install complete → dialog auto-dismisses
    showAllFilesAccessDialog() → second system dialog (Manage All Files)
    ↓ MainActivity visible
```

**Problem:** On first install the permission dialog appeared within 250ms, before any app UI rendered. On reinstall (files already present), `installIfNeeded()` returned immediately with no dialog at all — the user never saw any branded screen.

### After (new first-launch flow)

```
App opens
    ↓ onCreate()
    ImageFsInstaller.installIfNeeded()
    ↓ (internal storage, no permissions required)
    DownloadProgressDialog — FULL SCREEN
        [app logo]
        Winlator Star Bionic
        Bionic V1.0
        First launch setup
        [═══════ gray progress bar ═══════]
        Installing... X%
    ↓ install complete → closeOnUiThread() → showPermissionsButton()
    [All Files Access Required]  ← user taps
    ↓ close dialog
    doPermissionsFlow()
        → requestAppPermissions() (READ/WRITE/MANAGE storage)
        → showAllFilesAccessDialog() if SDK ≥ 30 + not manager
        → POST_NOTIFICATIONS if SDK ≥ 33 + not granted
    ↓ MainActivity visible
```

**Key insight:** `ImageFs.find(context)` uses `context.getFilesDir()` — internal storage. Installation does **not** require `READ_EXTERNAL_STORAGE` or `WRITE_EXTERNAL_STORAGE`. This means `installIfNeeded()` can safely run before permissions are granted.

---

## 2. Architecture

```
MainActivity.onCreate()
    └─ ImageFsInstaller.installIfNeeded(activity)
           └─ if not valid/outdated → installFromAssets(activity)
                  ├─ new DownloadProgressDialog(activity)
                  ├─ dialog.show(R.string.installing_system_files)
                  └─ ExecutorService.execute(lambda$installFromAssets$2)
                         ├─ TarCompressorUtils.extract(XZ, ...)
                         │       └─ lambda$installFromAssets$1 (progress callback)
                         │               └─ runOnUiThread → dialog.setProgress(n)
                         └─ on finish: dialog.closeOnUiThread()
                                └─ runOnUiThread → Lambda0.run()
                                       └─ dialog.showPermissionsButton()
                                              ├─ LLBottomBar.setVisibility(VISIBLE)
                                              └─ BTCancel.setOnClickListener(
                                                     Lambda1(Lambda2(dialog, activity)))
                                                         └─ on tap:
                                                                dialog.close()
                                                                activity.doPermissionsFlow()
```

---

## 3. Job 1 — Layout Replacement

**File:** `patches/res/layout/download_progress_dialog.xml`  
**Touch type:** Replaced entirely  
**Applied by:** `cp patches/res/layout/download_progress_dialog.xml apktool_out/res/layout/download_progress_dialog.xml`

### Original layout

Small card-style dialog with a `CircularProgressIndicator` and label:
```
FrameLayout (fill_parent × fill_parent, gravity=center)
  └─ LinearLayout (wrap_content × wrap_content, card background)
       ├─ CircularProgressIndicator (id=0x7f090073) 64dp
       ├─ TextView "X%" (id=0x7f090160)
       ├─ TextView label (id=0x7f09017c)
       └─ LLBottomBar (gone) → BTCancel
```

### New layout

Full-screen splash with `ScrollView` root (supports landscape):

```xml
<?xml version="1.0" encoding="utf-8"?>
<ScrollView android:fillViewport="true" android:background="#000000"
  android:layout_width="fill_parent" android:layout_height="fill_parent"
  xmlns:android="http://schemas.android.com/apk/res/android">
    <LinearLayout android:orientation="vertical" android:gravity="center"
      android:paddingTop="24.0dip" android:paddingBottom="24.0dip"
      android:layout_width="fill_parent" android:layout_height="wrap_content">

        <ImageView android:src="@mipmap/ic_launcher"
          android:scaleType="fitCenter"
          android:layout_width="80.0dip" android:layout_height="80.0dip"
          android:layout_marginBottom="16.0dip" />

        <TextView android:text="Winlator Star Bionic"
          android:textSize="28.0dip" android:textColor="#FFFFFF"
          android:textStyle="bold" android:layout_marginBottom="4.0dip"
          android:layout_width="wrap_content" android:layout_height="wrap_content" />

        <TextView android:text="Bionic V1.0"
          android:textSize="13.0dip" android:textColor="#888888"
          android:layout_marginBottom="16.0dip"
          android:layout_width="wrap_content" android:layout_height="wrap_content" />

        <TextView android:text="First launch setup"
          android:textSize="16.0dip" android:textColor="#AAAAAA"
          android:layout_marginBottom="32.0dip"
          android:layout_width="wrap_content" android:layout_height="wrap_content" />

        <!-- Reuses existing ID 0x7f090073 — cast changed to ProgressBar in smali -->
        <ProgressBar android:id="@id/CircularProgressIndicator"
          style="?android:attr/progressBarStyleHorizontal"
          android:max="100" android:progress="0"
          android:progressTint="#CCCCCC"
          android:progressBackgroundTint="#444444"
          android:layout_marginLeft="48.0dip" android:layout_marginRight="48.0dip"
          android:layout_width="fill_parent" android:layout_height="wrap_content" />

        <!-- Progress text — id=0x7f090160 -->
        <TextView android:id="@id/TVProgress"
          android:text="Installing... 0%"
          android:textColor="#FFFFFF" android:textSize="14.0dip"
          android:layout_marginTop="12.0dip"
          android:layout_width="wrap_content" android:layout_height="wrap_content" />

        <!-- Hidden compat view — keeps smali show(I) from NPE on setText -->
        <TextView android:id="@id/TextView"
          android:visibility="gone"
          android:layout_width="wrap_content" android:layout_height="wrap_content" />

        <!-- Permissions button container — shown by showPermissionsButton() -->
        <LinearLayout android:id="@id/LLBottomBar"
          android:visibility="gone" android:gravity="center"
          android:layout_marginTop="24.0dip"
          android:layout_width="fill_parent" android:layout_height="wrap_content">
            <Button android:id="@id/BTCancel"
              android:text="All Files Access Required"
              android:textColor="#FFFFFF" android:backgroundTint="#333333"
              android:layout_marginLeft="48.0dip" android:layout_marginRight="48.0dip"
              android:layout_width="fill_parent" android:layout_height="wrap_content" />
        </LinearLayout>
    </LinearLayout>
</ScrollView>
```

### ID reuse rationale

All view IDs in the new layout are reused from the original. No new IDs are introduced — `public.xml` is untouched.

| ID name | Hex value | Original use | New use |
|---|---|---|---|
| `CircularProgressIndicator` | `0x7f090073` | `CircularProgressIndicator` | `ProgressBar` (horizontal) |
| `TVProgress` | `0x7f090160` | "X%" label | "Installing... X%" label |
| `TextView` | `0x7f09017c` | Download label | Hidden compat view |
| `LLBottomBar` | `0x7f090093` | Cancel bar | Permissions button container |
| `BTCancel` | `0x7f09000d` | Cancel button | "All Files Access Required" button |

---

## 4. Job 2 — DownloadProgressDialog.smali

**File:** `patches/smali_classes10/com/winlator/cmod/core/DownloadProgressDialog.smali`  
**DEX:** `smali_classes10`  
**Touch type:** Patched (3 method changes + 1 method added)

### 4.1 `create()` — window becomes full-screen

**Original:** small card dialog with default system theme  
**New:** adds `setLayout(MATCH_PARENT, MATCH_PARENT)` + transparent background + `screenOrientation=SENSOR`

```smali
# After existing clearFlags calls (inside if-eqz v0, :cond_1 block):

    .line 35
    const/4 v1, -0x1              # MATCH_PARENT = -1

    invoke-virtual {v0, v1, v1}, Landroid/view/Window;->setLayout(II)V

    new-instance v2, Landroid/graphics/drawable/ColorDrawable;
    const/4 v3, 0x0               # Color.TRANSPARENT
    invoke-direct {v2, v3}, Landroid/graphics/drawable/ColorDrawable;-><init>(I)V
    invoke-virtual {v0, v2}, Landroid/view/Window;->setBackgroundDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 36
    invoke-virtual {v0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    const/4 v3, 0x4               # ActivityInfo.SCREEN_ORIENTATION_SENSOR = 4
    iput v3, v2, Landroid/view/WindowManager$LayoutParams;->screenOrientation:I
    invoke-virtual {v0, v2}, Landroid/view/Window;->setAttributes(Landroid/view/WindowManager$LayoutParams;)V

    :cond_1
    return-void
```

> **Why transparent background?** `Theme.Dialog` (0x1030011) renders rounded corners and a shadow by default. Setting a transparent `ColorDrawable` on the window removes the dialog chrome so the layout's own black background fills the screen cleanly.

> **Why `.locals 4`?** `v0`=window, `v1`=constant(−1), `v2`=ColorDrawable then LayoutParams (reused), `v3`=0 then 4 (reused). Four locals suffice; the values of v2/v3 from the ColorDrawable block are not needed after `setBackgroundDrawable`.

### 4.2 `setProgress()` — CircularProgressIndicator → ProgressBar

**Original cast:**
```smali
check-cast v0, Lcom/google/android/material/progressindicator/CircularProgressIndicator;
invoke-virtual {v0, p1}, Lcom/google/android/material/progressindicator/CircularProgressIndicator;->setProgress(I)V
```

**New cast (same resource ID `0x7f090073`, view is now a ProgressBar in the layout):**
```smali
check-cast v0, Landroid/widget/ProgressBar;
invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setProgress(I)V
```

**Text change — "X%" → "Installing... X%":**
```smali
# Original:
const-string v2, "%"
invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

# New (prepend "Installing... " before the integer):
const-string v2, "Installing... "
invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
move-result-object v1
invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
move-result-object v1
const-string v2, "%"
invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
```

### 4.3 `showPermissionsButton()` — new method

Called by `Lambda0.run()` instead of `close()` when installation completes.

```smali
.method public showPermissionsButton()V
    .locals 5

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;
    if-eqz v0, :return

    # Show LLBottomBar (id 0x7f090093)
    const v1, 0x7f090093
    invoke-virtual {v0, v1}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :find_btn
    const/4 v2, 0x0               # View.VISIBLE
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V

    # Find BTCancel (id 0x7f09000d), wire click listener
    :find_btn
    const v1, 0x7f09000d
    invoke-virtual {v0, v1}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :return

    # Lambda2(this, activity) → Runnable: close() + doPermissionsFlow()
    iget-object v2, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->activity:Landroid/app/Activity;
    new-instance v3, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;
    invoke-direct {v3, p0, v2}, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;-><init>(Lcom/winlator/cmod/core/DownloadProgressDialog;Landroid/app/Activity;)V

    # Lambda1(runnable) → OnClickListener: calls runnable.run() on click
    new-instance v4, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda1;
    invoke-direct {v4, v3}, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda1;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {v1, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    :return
    return-void
.end method
```

> **Lambda chain:** `Lambda1` (existing `OnClickListener`) wraps a `Runnable` and calls it via `lambda$show$0`. `Lambda2` (new) is the `Runnable` that does the real work. This reuses the existing `Lambda1` mechanism rather than adding a third lambda type.

---

## 5. Job 3 — Lambda Files

### 5.1 Lambda0 — patched

**File:** `patches/smali_classes10/com/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda0.smali`  
**Touch type:** Patched  

This is the `Runnable` posted to `runOnUiThread()` by `closeOnUiThread()`. Originally called `close()`. Now calls `showPermissionsButton()`.

```smali
.method public final run()V
    .locals 1

    .line 0
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda0;->f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;

    # CHANGED: was close(), now showPermissionsButton()
    invoke-virtual {v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->showPermissionsButton()V

    return-void
.end method
```

> **Why only patch Lambda0 and not `closeOnUiThread()` itself?** `Lambda0` is constructed exclusively in `closeOnUiThread()` and is the only caller path to the original `close()`. Patching just `Lambda0.run()` is the minimal change — `closeOnUiThread()` remains structurally identical, and `close()` remains available for direct callers (`HttpUtils`, cancel button) that should still dismiss immediately.

### 5.2 Lambda2 — new file

**File:** `patches/smali_classes10/com/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2.smali`  
**Touch type:** Created  

`Runnable` that fires when the user taps "All Files Access Required". Holds references to both the dialog (to close it) and the activity (to call `doPermissionsFlow()`).

```smali
.class public final synthetic Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

.implements Ljava/lang/Runnable;

.field public final synthetic f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;
.field public final synthetic f$1:Landroid/app/Activity;

.method public synthetic constructor <init>(Lcom/winlator/cmod/core/DownloadProgressDialog;Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;
    iput-object p2, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$1:Landroid/app/Activity;
    return-void
.end method

.method public final run()V
    .locals 1

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;
    invoke-virtual {v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->close()V

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$1:Landroid/app/Activity;
    check-cast v0, Lcom/winlator/cmod/MainActivity;
    invoke-virtual {v0}, Lcom/winlator/cmod/MainActivity;->doPermissionsFlow()V

    return-void
.end method
```

> **Field naming:** `f$0` and `f$1` match D8's synthetic lambda field naming convention for compatibility with the decompiler and any future re-analysis.

---

## 6. Job 4 — MainActivity.smali

**File:** `patches/smali_classes8/com/winlator/cmod/MainActivity.smali`  
**DEX:** `smali_classes8`  
**Touch type:** Patched (2 changes: `onCreate()` block replaced + new method appended)

### 6.1 `onCreate()` — permission block removed, installIfNeeded always called

**Original block (lines 1357–1413):**
```smali
invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->requestAppPermissions()Z
move-result v5
if-nez v5, :cond_7
invoke-static {p0}, Lcom/winlator/cmod/xenvironment/ImageFsInstaller;->installIfNeeded(Lcom/winlator/cmod/MainActivity;)V
:cond_7
[SDK >= 30 → showAllFilesAccessDialog]
:cond_8
[SDK >= 33 → POST_NOTIFICATIONS request]
:cond_9 :goto_3
return-void
```

**Replacement (lines 1357–1363):**
```smali
    .line 147
    invoke-static {p0}, Lcom/winlator/cmod/xenvironment/ImageFsInstaller;->installIfNeeded(Lcom/winlator/cmod/MainActivity;)V

    .end local v10    # "selectedMenuItemId":I
    .end local v11    # "menuItemId":I
    :goto_3
    return-void
.end method
```

> **`:goto_3` must be kept.** `goto :goto_3` at line 1317 (earlier in `onCreate`) jumps here. Removing it entirely causes a smali assembler error: "Cannot get the location of a label that hasn't been placed yet." This label was discovered during CI run `24309244927` (first attempt failed) and restored in run `24309274626`.

### 6.2 `doPermissionsFlow()` — new public method

Contains all permission logic extracted from `onCreate()`:

```smali
.method public doPermissionsFlow()V
    .locals 3

    invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->requestAppPermissions()Z

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x1e             # Build.VERSION_CODES.R = 30
    if-lt v0, v1, :cond_0

    invoke-static {}, Landroid/os/Environment;->isExternalStorageManager()Z
    move-result v0
    if-nez v0, :cond_0

    invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->showAllFilesAccessDialog()V

    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x21             # Build.VERSION_CODES.TIRAMISU = 33
    if-lt v0, v1, :cond_1

    const-string v0, "android.permission.POST_NOTIFICATIONS"
    invoke-static {p0, v0}, Landroidx/core/app/ActivityCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I
    move-result v1
    if-eqz v1, :cond_1

    const/4 v1, 0x1
    new-array v2, v1, [Ljava/lang/String;
    const/4 v1, 0x0
    aput-object v0, v2, v1
    invoke-virtual {p0, v2, v1}, Lcom/winlator/cmod/MainActivity;->requestPermissions([Ljava/lang/String;I)V

    :cond_1
    return-void
.end method
```

---

## 7. Job 5 — CI Workflow

**File:** `.github/workflows/build.yml`  
**Touch type:** Patched

### Added lines in "Apply patches" step:

```yaml
- name: Apply patches
  run: |
    cp -r patches/smali_classes8 apktool_out/
    cp -r patches/smali_classes2 apktool_out/
    cp -r patches/smali_classes10 apktool_out/          # ← NEW: DownloadProgressDialog patches
    cp patches/AndroidManifest.xml apktool_out/AndroidManifest.xml
    cp patches/res/menu/main_menu.xml apktool_out/res/menu/main_menu.xml
    cp patches/res/layout/download_progress_dialog.xml \
       apktool_out/res/layout/download_progress_dialog.xml   # ← NEW: layout replacement
```

> **`cp -r patches/smali_classes10 apktool_out/`** copies the entire directory tree, so all three files (`DownloadProgressDialog.smali`, `Lambda0.smali`, `Lambda2.smali`) are applied in one step.

---

## 8. Source Code Path (build.gradle / Gradle project)

For developers working from the Winlator Bionic source tree rather than APK surgery.

### 8.1 `DownloadProgressDialog.java` — full rewrite

Rewrite the entire class. Key changes from original:

```java
package com.winlator.cmod.core;

import android.app.Activity;
import android.app.Dialog;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.winlator.cmod.MainActivity;
import com.winlator.cmod.R;

public class DownloadProgressDialog {
    private final Activity activity;
    private Dialog dialog;

    public DownloadProgressDialog(Activity activity) {
        this.activity = activity;
    }

    private void create() {
        if (dialog != null) return;

        dialog = new Dialog(activity, 0x1030011 /* Theme.Dialog */);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.setContentView(R.layout.download_progress_dialog);

        Window window = dialog.getWindow();
        if (window != null) {
            window.clearFlags(0x10);  // DIM_BEHIND
            window.clearFlags(0x8);   // NOT_TOUCHABLE

            // Full-screen overlay
            window.setLayout(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT
            );
            window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

            // Follow device rotation sensor
            WindowManager.LayoutParams lp = window.getAttributes();
            lp.screenOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR;
            window.setAttributes(lp);
        }
    }

    public void close() {
        try {
            if (dialog != null) dialog.dismiss();
        } catch (Exception ignored) {}
    }

    public void closeOnUiThread() {
        // Posts showPermissionsButton() to the UI thread (via Lambda0 equivalent)
        activity.runOnUiThread(this::showPermissionsButton);
    }

    public boolean isShowing() {
        return dialog != null && dialog.isShowing();
    }

    public void setProgress(int progress) {
        if (dialog == null) return;
        progress = Math.max(0, Math.min(100, progress));

        View pbView = dialog.findViewById(R.id.CircularProgressIndicator);
        if (pbView instanceof ProgressBar) {
            ((ProgressBar) pbView).setProgress(progress);
        }

        TextView tv = dialog.findViewById(R.id.TVProgress);
        if (tv != null) {
            tv.setText("Installing... " + progress + "%");
        }
    }

    /** Shows the "All Files Access Required" button when installation is complete. */
    public void showPermissionsButton() {
        if (dialog == null) return;

        View bar = dialog.findViewById(R.id.LLBottomBar);
        if (bar != null) bar.setVisibility(View.VISIBLE);

        View btn = dialog.findViewById(R.id.BTCancel);
        if (btn == null) return;

        btn.setOnClickListener(v -> {
            close();
            ((MainActivity) activity).doPermissionsFlow();
        });
    }

    public void show() {
        show((Runnable) null);
    }

    public void show(int textResId) {
        show(textResId, null);
    }

    public void show(int textResId, Runnable onCancelCallback) {
        if (isShowing()) return;
        close();
        if (dialog == null) create();

        if (textResId > 0) {
            TextView tv = dialog.findViewById(R.id.TextView);
            if (tv != null) tv.setText(textResId);
        }

        setProgress(0);

        if (onCancelCallback != null) {
            View cancelBtn = dialog.findViewById(R.id.BTCancel);
            if (cancelBtn != null) {
                cancelBtn.setOnClickListener(v -> onCancelCallback.run());
            }
            View cancelBar = dialog.findViewById(R.id.LLBottomBar);
            if (cancelBar != null) cancelBar.setVisibility(View.GONE);
        }

        dialog.show();
    }

    public void show(Runnable onCancelCallback) {
        show(0, onCancelCallback);
    }
}
```

### 8.2 `MainActivity.java` — two changes

**Change 1: In `onCreate()`, replace the permission block**

Find the section that calls `requestAppPermissions()` and replace it:

```java
// REMOVE this block entirely:
//   boolean needsPermissions = requestAppPermissions();
//   if (!needsPermissions) {
//       ImageFsInstaller.installIfNeeded(this);
//   }
//   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
//       showAllFilesAccessDialog();
//   }
//   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//       if (ContextCompat.checkSelfPermission(this, POST_NOTIFICATIONS) != PERMISSION_GRANTED) {
//           requestPermissions(new String[]{POST_NOTIFICATIONS}, 0);
//       }
//   }

// REPLACE WITH:
ImageFsInstaller.installIfNeeded(this);
```

**Change 2: Add `doPermissionsFlow()` as a new public method**

```java
/**
 * Runs the full storage + all-files + notifications permission flow.
 * Called from DownloadProgressDialog when the user taps the
 * "All Files Access Required" button after first-launch installation.
 */
public void doPermissionsFlow() {
    requestAppPermissions();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        if (!Environment.isExternalStorageManager()) {
            showAllFilesAccessDialog();
        }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                new String[]{Manifest.permission.POST_NOTIFICATIONS}, 0);
        }
    }
}
```

### 8.3 `build.gradle` additions

No new dependencies are required for the splash screen changes. If not already present, ensure `vectorDrawables.useSupportLibrary` is set (required for the existing `AppCompatDelegate` fix):

```groovy
android {
    defaultConfig {
        vectorDrawables.useSupportLibrary = true
    }
}
```

The `res/layout/download_progress_dialog.xml` replacement is a drop-in swap of an existing layout file. No new resource IDs — place the new XML at `app/src/main/res/layout/download_progress_dialog.xml`.

### 8.4 `R.java` — no changes required

All view IDs used by the new layout (`CircularProgressIndicator`, `TVProgress`, `TextView`, `LLBottomBar`, `BTCancel`) already exist in the original resource set. No new ID declarations are needed.

---

## 9. Critical Implementation Notes

### 9.1 `:goto_3` label must be preserved

Removing the permission block from `onCreate()` also removes the `:goto_3 :cond_9` labels at the end of the method. However, `goto :goto_3` appears **earlier** in `onCreate()` (line 1317 — the branch taken when `selectedMenuItemId` is set). If this label is missing the smali assembler fails silently with "Cannot get the location of a label that hasn't been placed yet."

**Fix:** Always keep a bare `:goto_3` label just before `return-void` at the end of `onCreate()`.

### 9.2 CircularProgressIndicator cast must change

The original `setProgress()` casts `findViewById(R.id.CircularProgressIndicator)` to `CircularProgressIndicator`. The new layout uses a standard `ProgressBar` at that same ID. Keeping the original cast causes a `ClassCastException` at runtime.

**Fix:** Change cast to `Landroid/widget/ProgressBar;` and update the invoke to `ProgressBar.setProgress(I)V`.

### 9.3 Installation uses internal storage — no permissions needed

`ImageFs.find(context)` resolves the root directory via `context.getFilesDir()` — the app's private internal files directory. This does **not** require `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, or `MANAGE_EXTERNAL_STORAGE`. The installation can run safely before any permissions are granted.

### 9.4 HttpUtils calls close() directly — not affected

`HttpUtils` (used for Wine downloads and content installation) calls `dialog.close()` directly, not `dialog.closeOnUiThread()`. The `Lambda0` change only affects the `closeOnUiThread()` path, which is exclusively called from `ImageFsInstaller.lambda$installFromAssets$2`. Other uses of `DownloadProgressDialog` are unaffected.

### 9.5 Dialog window transparent background

`Theme.Dialog` (theme `0x1030011`) renders a card with rounded corners and a shadow drop. After `setLayout(MATCH_PARENT, MATCH_PARENT)`, the dialog fills the screen but the card chrome remains, creating a dark border/shadow ring. Setting `window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT))` removes the chrome so the layout's `android:background="#000000"` fills cleanly edge-to-edge.

### 9.6 ScrollView required for landscape

In landscape orientation the screen height shrinks to ~350–400dp on most phones. The splash content (logo 80dp + margins + title + version + subtitle + progress bar + button) totals ~280–320dp minimum. `ScrollView` with `fillViewport="true"` ensures the content is visible without clipping in landscape while remaining centered in portrait.

---

## 10. CI Build Log

| Run | Commit | Result | Notes |
|---|---|---|---|
| 24308949901 | `451c58e` | ✅ | Initial full-screen splash layout + smali |
| 24309244927 | `703bf01` | ❌ | `:goto_3` label removed — smali assembler error |
| 24309274626 | `ff0275a` | ✅ | `:goto_3` restored |
| 24309318040 | `af5b869` | ✅ | Version text "Bionic V1.0" added |
| 24309488772 | `c5c49cd` | ✅ | Auto-rotation + ScrollView |
| *(stable)* | `v1.0.1` | ✅ | Stable release |

---

## 11. File Touch Map

| File | Location | Touch type | Committed in |
|---|---|---|---|
| `download_progress_dialog.xml` | `patches/res/layout/` | **Replaced** | `451c58e` → updated through `c5c49cd` |
| `DownloadProgressDialog.smali` | `patches/smali_classes10/com/winlator/cmod/core/` | **Patched** | `451c58e` → updated through `c5c49cd` |
| `DownloadProgressDialog$$ExternalSyntheticLambda0.smali` | `patches/smali_classes10/com/winlator/cmod/core/` | **Patched** | `703bf01` |
| `DownloadProgressDialog$$ExternalSyntheticLambda2.smali` | `patches/smali_classes10/com/winlator/cmod/core/` | **Created** | `703bf01` |
| `MainActivity.smali` | `patches/smali_classes8/com/winlator/cmod/` | **Patched** | `703bf01` → `ff0275a` |
| `build.yml` | `.github/workflows/` | **Patched** | `451c58e` |
| `ImageFsInstaller.smali` | `smali_classes12/com/winlator/cmod/xenvironment/` | Read-only (analysed) | — |
| `ImageFs.smali` | `smali_classes12/com/winlator/cmod/xenvironment/` | Read-only (analysed) | — |

---

## 12. Integration Package

All patch files, smali snippets, and this report are bundled in a single zip attached to the v1.0.1 stable release:

**[star-splash-integration.zip](https://github.com/The412Banner/star-test/releases/download/v1.0.1/star-splash-integration.zip)**

```
star-splash-integration/
├── STAR_SPLASH_REPORT.md                   This report
├── patches/
│   ├── res/layout/
│   │   └── download_progress_dialog.xml    Full-screen layout replacement
│   └── smali_classes10/com/winlator/cmod/core/
│       ├── DownloadProgressDialog.smali              Patched (full file)
│       ├── DownloadProgressDialog$$ExternalSyntheticLambda0.smali   Patched
│       └── DownloadProgressDialog$$ExternalSyntheticLambda2.smali   New
└── snippets/
    ├── 1_DownloadProgressDialog_java.java  Full Java source equivalent
    ├── 2_MainActivity_additions.java       doPermissionsFlow() + onCreate change
    ├── 3_download_progress_dialog_xml.xml  Layout (same as patches/)
    └── 4_build_yml_patch.txt               The two lines added to build.yml
```

---

*Report version: 1.0 — 2026-04-12 (v1.0.1 stable verified on device)*  
*Integration repo: https://github.com/The412Banner/star-test*
