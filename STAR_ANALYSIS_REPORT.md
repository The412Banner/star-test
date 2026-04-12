# Star Bionic — Full Integration Report
### GOG · Epic Games · Amazon Games Store Integration

**Prepared by:** The412Banner / BannerHub Team  
**Date:** 2026-04-11 (device verified)  
**APK analysed:** `star-Bionic_original.apk`  
**Integration repo:** https://github.com/The412Banner/star-test  
**Reference builds:** Ludashi-plus · REF4IK-Banner  

---

## Implementation Status

| Phase | Task | Status |
|---|---|---|
| 1 | Repo created + base APK uploaded | ✅ |
| 1 | 29 extension Java files added to `extension/` | ✅ |
| 1 | `testkey.pk8` / `testkey.x509.pem` added | ✅ |
| 2 | `MainActivity.smali` — sparse-switch + 3 handler blocks | ✅ |
| 2 | `MainActivity.smali` — `setCompatVectorFromResourcesEnabled` fix | ✅ |
| 2 | `R$id.smali` — 3 field constants | ✅ |
| 3 | `main_menu.xml` — 3 store items | ✅ |
| 3 | `public.xml` — 3 ID pins (merged, not replaced) | ✅ |
| 3 | `AndroidManifest.xml` — 9 activity declarations | ✅ |
| 4 | CI workflow (build.yml) — full 17-step pipeline | ✅ |
| 5 | CI build green — run `24295767143` | ✅ |
| 5 | `classes17.dex` (1.2M, 71 classes) confirmed in APK | ✅ |
| 5 | Device install — app launches, no crash | ✅ |
| 5 | All 3 store entries visible in nav drawer | ✅ |
| 6 | GOG: Main / Login / Games Activities all launch | ✅ |
| 6 | Epic: Main / Login / Games Activities all launch | ✅ |
| 6 | Amazon: Main / Login / Games Activities all launch | ✅ |
| 7 | End-to-end download + shortcut + launch | ✅ Verified on device |
| 7 | Stable release `v1.0.0` | ✅ https://github.com/The412Banner/star-test/releases/tag/v1.0.0 |

---

## Executive Summary

Star Bionic shares the exact same Java source package (`com.winlator.cmod.*`) as the proven Ludashi-plus and REF4IK-Banner builds. This means all 29 store Java extension files transfer directly with zero rewrites. The integration required:

- **2 smali patches** — extend the navigation dispatch switch + pin 3 new resource IDs
- **3 resource patches** — menu items, ID pins, manifest activity declarations
- **1 CI workflow** — compiles the 29 Java files to `classes17.dex` and injects it

All 9 store Activities (GOG, Epic, Amazon × Main/Login/Games) launch cleanly on device. Three non-obvious issues were discovered and fixed during this process — documented fully in Section 14.

---

## 1. APK Identity

| Field | Value |
|---|---|
| Package name (manifest) | `com.winlator.star` |
| Source package | `com.winlator.cmod.*` |
| App label | `star Bionic` |
| Version name | `Bionic V1.0` |
| Version code | `20` |
| Min SDK | 26 (Android 8.0) |
| Target SDK | 28 (Android 9) |
| APK size | ~547 MB |
| DEX count | 16 (`classes.dex` → `classes16.dex`) |
| New DEX slot used | `classes17.dex` |

---

## 2. Architecture Overview

```
Android Navigation Drawer (MainActivity)
    ↓  user taps store item
    onNavigationItemSelected() — sparse-switch on resource ID
    ↓  sswitch_8 / sswitch_9 / sswitch_a
    startActivity(GogMainActivity / EpicMainActivity / AmazonMainActivity)
    ↓  user logs in, browses library, taps Download
    store DownloadManager — parallel HTTP download into imagefs/
    ↓  download complete
    LudashiLaunchBridge.addToLauncher()
        → reflection → ContainerManager.getContainers()
        → AlertDialog: pick Wine container
        → write .desktop to container Desktop dir
    ↓
    ShortcutsFragment scans Desktop dirs on next load
    ↓  user taps shortcut
    XServerDisplayActivity → Wine → FEXCore/Box64 → game.exe
```

---

## 3. Navigation & Dispatch

**Activity:** `com.winlator.cmod.MainActivity`  
**DEX:** `smali_classes8`  
**Method:** `onNavigationItemSelected()` — line 1413  
**Dispatch type:** `sparse-switch` at line 1448

### Existing switch entries

| ID name | Hex | Handler |
|---|---|---|
| `main_menu_about` | `0x7f090269` | `showAboutDialog()` |
| `main_menu_adrenotools_gpu_drivers` | `0x7f09026b` | `AdrenotoolsFragment` |
| `main_menu_containers` | `0x7f09026c` | `ContainersFragment` |
| `main_menu_contents` | `0x7f09026d` | `ContentsFragment` |
| `main_menu_input_controls` | `0x7f090271` | `InputControlsFragment` |
| `main_menu_saves` | `0x7f090279` | `SavesFragment` |
| `main_menu_settings` | `0x7f09027b` | `SettingsFragment` |
| `main_menu_shortcuts` | `0x7f09027c` | `ShortcutsFragment` |

### New store entries added

| ID name | Hex | Activity |
|---|---|---|
| `main_menu_gog` | `0x7f0903a6` | `GogMainActivity` |
| `main_menu_epic` | `0x7f0903a7` | `EpicMainActivity` |
| `main_menu_amazon` | `0x7f0903a8` | `AmazonMainActivity` |

> **ID selection:** IDs `0x7f09027f–0x7f090281` (immediately after `main_menu_toggle_fullscreen`) are occupied by MaterialComponents (`masked`, `material_clock_display`, `material_clock_face`). The 3 slots after the last `public.xml` entry (`zero_corner_chip` = `0x7f0903a5`) are used instead.

---

## 4. Container & Shortcut System

### Container API (via reflection)

**Class:** `com.winlator.cmod.container.Container` — DEX `smali_classes14`

| Method | Returns | Description |
|---|---|---|
| `getRootDir()` | `File` | Wine prefix root directory |
| `getDesktopDir()` | `File` | `rootDir/.wine/drive_c/users/xuser/Desktop/` |
| `getName()` | `String` | User-visible container name |
| `getDrives()` | `String` | Drive letter mappings |

**Default Wine drive mappings:**

| Letter | Android path | Notes |
|---|---|---|
| `C:` | Wine prefix | Standard Wine C drive |
| `D:` | `/sdcard/Download` | — |
| `F:` | `/sdcard` | External storage |
| `Z:` | `{filesDir}/imagefs/` | Full Linux root — game install target |

The `Z:` mapping is confirmed in `ShortcutsFragment.smali` lines 851–863: any path containing `/imagefs/` becomes a `Z:` path in the shortcut.

### Shortcut format

Written to `container.getDesktopDir()/{gameName}.desktop`:

```ini
[Desktop Entry]
Name=Game Name
Exec=wine Z:\\gog_games\\GameDir\\game.exe
Icon=
Type=Application
StartupWMClass=explorer

[Extra Data]
```

`ContainerManager.loadShortcuts()` scans all container Desktop dirs automatically. No extra code is needed for the game to appear in the Shortcuts tab.

### Install path strategy

Games are installed under `imagefs/` so Wine's `Z:` drive can reach them without any extra drive mapping:

| Store | Android path | Wine path |
|---|---|---|
| GOG | `{filesDir}/imagefs/gog_games/{title}/` | `Z:\gog_games\{title}\game.exe` |
| Epic | `{filesDir}/imagefs/epic_games/{title}/` | `Z:\epic_games\{title}\game.exe` |
| Amazon | `{filesDir}/imagefs/amazon_games/{title}/` | `Z:\amazon_games\{title}\game.exe` |

`{filesDir}` resolves to the Star-specific data directory (`/data/user/0/com.winlator.star/files/`) at runtime via `Context.getFilesDir()`. No code change needed.

---

## 5. Extension Files

All 29 Java files live in `extension/` in the repo root. They compile against `android.jar` alone — no Winlator stubs, no AAR dependencies. `LudashiLaunchBridge` uses Java reflection to call `ContainerManager` at runtime.

| File | Package | Size | Purpose |
|---|---|---|---|
| `GogGame.java` | `store` | 795B | POJO: game ID, title, size |
| `GogInstallPath.java` | `store` | 1.2KB | Returns `{filesDir}/imagefs/gog_games/{name}` |
| `GogLaunchHelper.java` | `store` | 400B | Delegates to `LudashiLaunchBridge` |
| `GogTokenRefresh.java` | `store` | 3.1KB | HTTP token refresh (GOG OAuth) |
| `GogDownloadManager.java` | `store` | 64KB | Full GOG content-system API + parallel download |
| `GogLoginActivity.java` | `store` | 7.2KB | WebView OAuth login |
| `GogMainActivity.java` | `store` | 6.7KB | Entry Activity — shows login or library |
| `GogGamesActivity.java` | `store` | 66KB | Library list, download UI, shortcut creation |
| `EpicGame.java` | `store` | 1.6KB | POJO: appId, title, install size |
| `EpicCredentialStore.java` | `store` | 3.8KB | SharedPreferences wrapper (epic_prefs) |
| `EpicAuthClient.java` | `store` | 9.6KB | OAuth token exchange + refresh |
| `EpicApiClient.java` | `store` | 11.7KB | Catalog + manifest API |
| `EpicDownloadManager.java` | `store` | 45KB | Chunked CDN download engine |
| `EpicLoginActivity.java` | `store` | 5.4KB | WebView OAuth (reads body via evaluateJavascript) |
| `EpicMainActivity.java` | `store` | 5.8KB | Entry Activity |
| `EpicGamesActivity.java` | `store` | 56KB | Library list, download UI, shortcut creation |
| `AmazonGame.java` | `store` | 1.5KB | POJO: asin, title, version |
| `AmazonCredentialStore.java` | `store` | 4.9KB | SharedPreferences wrapper (amazon_prefs) |
| `AmazonPKCEGenerator.java` | `store` | 2.7KB | PKCE code verifier + challenge |
| `AmazonAuthClient.java` | `store` | 9.8KB | PKCE device registration flow |
| `AmazonApiClient.java` | `store` | 13KB | GetEntitlements + manifest fetch |
| `AmazonManifest.java` | `store` | 12.8KB | Protobuf manifest parser |
| `AmazonDownloadManager.java` | `store` | 18.7KB | Parallel download + XZ/LZMA decompress |
| `AmazonSdkManager.java` | `store` | 10.4KB | FuelSDK DLL deployment |
| `AmazonLaunchHelper.java` | `store` | 11.2KB | fuel.json + FuelPump env vars |
| `AmazonLoginActivity.java` | `store` | 7.2KB | PKCE WebView login |
| `AmazonMainActivity.java` | `store` | 6.8KB | Entry Activity |
| `AmazonGamesActivity.java` | `store` | 56.5KB | Library list, download UI, shortcut creation |
| `LudashiLaunchBridge.java` | `store` | 5.7KB | Reflection-based container picker + .desktop writer |

**Runtime dependencies (downloaded by CI, bundled in classes17.dex):**

| Library | Version | Maven coordinate | Purpose |
|---|---|---|---|
| `org.json` | 20240303 | `org.json:json:20240303` | JSON parsing (all stores) |
| `commons-compress` | 1.26.0 | `org.apache.commons:commons-compress:1.26.0` | Amazon XZ/LZMA decompression |

---

## 6. Complete File Change Log

### Files added (new — did not exist before)

| File | Size | Purpose |
|---|---|---|
| `extension/` (29 × .java) | ~430KB total | All store source code |
| `patches/smali_classes8/com/winlator/cmod/MainActivity.smali` | 55KB | Full patched MainActivity |
| `patches/smali_classes2/com/winlator/cmod/R$id.smali` | 30KB | Full patched R$id |
| `patches/res/menu/main_menu.xml` | 1.5KB | Navigation drawer menu with 3 store items |
| `patches/res/values/public.xml` | 254B | 3 pinned resource IDs (merged into full public.xml by CI) |
| `patches/AndroidManifest.xml` | 8.6KB | Full manifest with 9 new activity declarations |
| `.github/workflows/build.yml` | 4.5KB | Full CI pipeline |
| `testkey.pk8` | — | AOSP signing key (private key) |
| `testkey.x509.pem` | — | AOSP signing key (certificate) |
| `STAR_ANALYSIS_REPORT.md` | — | This document |
| `STAR_TASK_LIST.md` | — | Phase task list |

### Files modified (patched from original)

| File | Original location | What changed |
|---|---|---|
| `MainActivity.smali` | `smali_classes8/com/winlator/cmod/` | +3 sswitch entries, +3 handler blocks, +`setCompatVectorFromResourcesEnabled` |
| `R$id.smali` | `smali_classes2/com/winlator/cmod/` | +3 field constants |
| `main_menu.xml` | `res/menu/` | +3 `<item>` elements (GOG, Epic Games, Amazon Games) |
| `AndroidManifest.xml` | repo root | +9 `<activity>` declarations |

### Files generated by CI (not stored in repo)

| File | Size | How generated |
|---|---|---|
| `classes17.dex` | 1.2MB | `javac` + `d8` from `extension/*.java` |
| `star-bionic-{tag}.apk` | ~573MB | `apktool b` + `ab_*` reinject + `classes17.dex` inject + zipalign + apksigner |

---

## 7. Exact Code Added and Changed

### 7.1 `patches/smali_classes8/com/winlator/cmod/MainActivity.smali`

#### Change 1 — VectorDrawableCompat fix (before super.onCreate)

Inserted at line 1076, before the existing `invoke-super` call:

```smali
    .line 78
    const/4 v0, 0x1
    invoke-static {v0}, Landroidx/appcompat/app/AppCompatDelegate;->setCompatVectorFromResourcesEnabled(Z)V

    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onCreate(Landroid/os/Bundle;)V
```

**Why:** apktool's rebuild loses the Gradle-time VectorDrawableCompat configuration. AppCompat's `checkVectorDrawableSetup()` throws `IllegalStateException` on launch without this call. Must be before `super.onCreate()`.

#### Change 2 — 3 handler blocks (before :sswitch_data_0, around line 1540)

```smali
    .line 428
    :sswitch_8
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/GogMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0

    .line 429
    :sswitch_9
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/EpicMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0

    .line 430
    :sswitch_a
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/AmazonMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0

    nop
```

**Why `v3` not `v2`:** The method sets `v2 = 0x1` (boolean true return value) early. Writing a class reference into `v2` causes `VerifyError: register v2 has type IntegerConstant but expected Boolean` at install time. `v3` is free.

#### Change 3 — sparse-switch entries (at :sswitch_data_0, around line 1566)

```smali
    :sswitch_data_0
    .sparse-switch
        0x7f090269 -> :sswitch_7   # about (unchanged)
        0x7f09026b -> :sswitch_6   # adrenotools (unchanged)
        0x7f09026c -> :sswitch_5   # containers (unchanged)
        0x7f09026d -> :sswitch_4   # contents (unchanged)
        0x7f090271 -> :sswitch_3   # input_controls (unchanged)
        0x7f090279 -> :sswitch_2   # saves (unchanged)
        0x7f09027b -> :sswitch_1   # settings (unchanged)
        0x7f09027c -> :sswitch_0   # shortcuts (unchanged)
        0x7f0903a6 -> :sswitch_8   # GOG ← NEW
        0x7f0903a7 -> :sswitch_9   # Epic ← NEW
        0x7f0903a8 -> :sswitch_a   # Amazon ← NEW
    .end sparse-switch
```

---

### 7.2 `patches/smali_classes2/com/winlator/cmod/R$id.smali`

Added after the `main_menu_toggle_fullscreen` line:

```smali
.field public static final main_menu_gog:I = 0x7f0903a6
.field public static final main_menu_epic:I = 0x7f0903a7
.field public static final main_menu_amazon:I = 0x7f0903a8
```

---

### 7.3 `patches/res/menu/main_menu.xml` (full file — replaces original)

```xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <group android:checkableBehavior="single">
        <item android:icon="@drawable/icon_shortcut"
              android:id="@id/main_menu_shortcuts"
              android:title="@string/shortcuts" />
        <item android:icon="@drawable/icon_container"
              android:id="@id/main_menu_containers"
              android:title="@string/containers" />
        <item android:icon="@drawable/icon_input_controls"
              android:id="@id/main_menu_input_controls"
              android:title="@string/input_controls" />
        <item android:icon="@drawable/icon_open"
              android:id="@id/main_menu_contents"
              android:title="@string/contents" />
        <item android:icon="@drawable/icon_open"
              android:id="@id/main_menu_adrenotools_gpu_drivers"
              android:title="@string/adrenotools_gpu_drivers" />
        <item android:icon="@drawable/icon_save"
              android:id="@id/main_menu_saves"
              android:title="@string/saves" />
        <!-- Store integrations -->
        <item android:icon="@drawable/icon_open"
              android:id="@id/main_menu_gog"
              android:title="GOG" />
        <item android:icon="@drawable/icon_open"
              android:id="@id/main_menu_epic"
              android:title="Epic Games" />
        <item android:icon="@drawable/icon_open"
              android:id="@id/main_menu_amazon"
              android:title="Amazon Games" />
        <item android:icon="@drawable/icon_settings"
              android:id="@id/main_menu_settings"
              android:title="@string/settings" />
        <item android:icon="@drawable/icon_about"
              android:id="@id/main_menu_about"
              android:title="@string/about" />
    </group>
</menu>
```

---

### 7.4 `patches/res/values/public.xml` (merged by CI — not a replacement)

This file is **not copied directly**. The CI injects these 3 entries into the existing 4856-line `public.xml` via `sed`:

```xml
<public type="id" name="main_menu_gog"    id="0x7f0903a6" />
<public type="id" name="main_menu_epic"   id="0x7f0903a7" />
<public type="id" name="main_menu_amazon" id="0x7f0903a8" />
```

**Why merging is critical:** The `apktool_out/res/values/public.xml` generated on decompile contains 4856 entries pinning every AppCompat, Material, and AndroidX resource ID. Replacing this file with a 3-entry version causes aapt2 to reassign all those IDs. The compiled DEX code still references the original IDs — resulting in wrong drawables, broken themes, and `IllegalStateException: VectorDrawableCompat` crash on launch.

---

### 7.5 `patches/AndroidManifest.xml` — 9 new `<activity>` declarations

Added inside `<application>`:

```xml
<!-- GOG Game Store -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>

<!-- Epic Games Store -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>

<!-- Amazon Games -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
```

---

### 7.6 `.github/workflows/build.yml` (complete final version)

```yaml
name: Build Star Bionic + Store Integration

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write          # Required for gh release create

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Java 11
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: '11'

      - name: Install apktool
        run: |
          wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O apktool.jar
          printf '#!/bin/sh\njava -jar /usr/local/bin/apktool.jar "$@"\n' > apktool
          chmod +x apktool
          sudo mv apktool /usr/local/bin/apktool
          sudo mv apktool.jar /usr/local/bin/apktool.jar

      - name: Download base APK
        run: |
          gh release download base-apk --pattern "*.apk" --output base.apk
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Decompile APK
        run: |
          apktool d base.apk -o apktool_out -f

      - name: Apply patches
        run: |
          # Copy smali and resource patches individually — public.xml is MERGED, not replaced
          cp -r patches/smali_classes8 apktool_out/
          cp -r patches/smali_classes2 apktool_out/
          cp patches/AndroidManifest.xml apktool_out/AndroidManifest.xml
          cp patches/res/menu/main_menu.xml apktool_out/res/menu/main_menu.xml
          # Inject 3 new IDs into existing public.xml (4856 entries) before </resources>
          sed -i 's|</resources>|    <public type="id" name="main_menu_gog" id="0x7f0903a6" />\n    <public type="id" name="main_menu_epic" id="0x7f0903a7" />\n    <public type="id" name="main_menu_amazon" id="0x7f0903a8" />\n</resources>|' \
            apktool_out/res/values/public.xml

      - name: Remove ab_*.png pseudo-PNG files before aapt2
        run: |
          # Star has ab_0001..ab_N, ab_gear_0001..N, ab_quilt_0001..N animation frames
          # These are binary data, not real PNGs — aapt2 rejects them
          find apktool_out/res/drawable -name 'ab_*.png' -delete
          rm -f apktool_out/res/drawable/animated_background.xml
          # Strip ALL ab_* public.xml entries (pattern must cover all three variants)
          sed -i '/name="ab_\|name="animated_background/d' \
            apktool_out/res/values/public.xml

      - name: Download org.json dependency
        run: |
          wget -q "https://repo1.maven.org/maven2/org/json/json/20240303/json-20240303.jar" -O org-json.jar

      - name: Download commons-compress (Amazon LZMA)
        run: |
          wget -q "https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar" -O commons-compress.jar

      - name: Compile store extension → classes17.dex
        run: |
          ANDROID_JAR=$(ls $ANDROID_SDK_ROOT/platforms/android-*/android.jar 2>/dev/null | sort -V | tail -1)
          mkdir -p ext_classes
          javac -source 8 -target 8 \
            -cp "$ANDROID_JAR:org-json.jar:commons-compress.jar" \
            -d ext_classes \
            extension/*.java
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          mkdir -p ext_dex
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/d8 \
            --release --min-api 26 --output ext_dex \
            $(find ext_classes -name '*.class') \
            org-json.jar \
            commons-compress.jar

      - name: Rebuild APK
        run: apktool b apktool_out -o rebuilt-unsigned.apk

      - name: Re-inject ab_*.png and animated_background.xml from base APK
        run: |
          mkdir -p ab_reinject
          unzip -q base.apk \
            'res/drawable/ab_*.png' \
            'res/drawable/animated_background.xml' \
            -d ab_reinject 2>/dev/null || true
          INJECTED=$(find ab_reinject -type f | wc -l)
          if [ "$INJECTED" -gt 0 ]; then
            (cd ab_reinject && zip -r ../rebuilt-unsigned.apk res/)
          fi

      - name: Inject classes17.dex
        run: |
          cp ext_dex/classes.dex classes17.dex
          zip -j rebuilt-unsigned.apk classes17.dex

      - name: Zipalign
        run: |
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/zipalign -p -f 4 \
            rebuilt-unsigned.apk aligned.apk

      - name: Sign APK
        run: |
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          APK_NAME="star-bionic-${{ github.ref_name }}.apk"
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/apksigner sign \
            --key testkey.pk8 \
            --cert testkey.x509.pem \
            --v1-signing-enabled true \
            --v2-signing-enabled true \
            --v3-signing-enabled true \
            --out "$APK_NAME" \
            aligned.apk
          echo "APK_NAME=$APK_NAME" >> $GITHUB_ENV

      - name: Create release and upload APK
        run: |
          gh release create "${{ github.ref_name }}" \
            "${{ env.APK_NAME }}" \
            --title "Star Bionic ${{ github.ref_name }}" \
            --prerelease \
            --notes "Pre-release: GOG + Epic + Amazon store integration"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 8. Store API Reference

### GOG
| Item | Value |
|---|---|
| Auth URL | `https://auth.gog.com/auth?client_id=46899977096215655&redirect_uri=https://embed.gog.com/on_login_success?origin=client&response_type=code` |
| Token URL | `https://auth.gog.com/token` |
| Client ID | `46899977096215655` (public) |
| Client secret | `9d85c43b1482497dbbce61f6e4aa173a433796eeae2ca8c5f6129f2dc4de46d9` (public) |
| Library | `https://embed.gog.com/account/getFilteredProducts?mediaType=1` |
| Build API | `https://content-system.gog.com/products/{id}/os/windows/builds?generation=2` |
| Old game fallback | `https://api.gog.com/products/{id}?expand=downloads` → direct `.exe` URL |

### Epic Games
| Item | Value |
|---|---|
| Login | WebView → `https://www.epicgames.com/id/login` |
| Auth code | Read `document.body.innerText` on redirect to `epicgames.com/id/api/redirect` → parse `authorizationCode` JSON field |
| Library | `https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/public/assets/v2/` |
| CDN order | Fastly (`egdownload.fastly-edge.com`) → Akamai (`epicgames-download1.akamaized.net`) → Cloudflare (last resort, token-gated) |
| Chunk group | **Decimal** `"%02d".format(groupNum)` — NOT hex |
| `ChunkFilesizeList` | **Hex strings** — parse with `Long.parseLong(s, 16)` |
| `windowSize` | Uncompressed size (use for install size display) |
| `fileSize` | Compressed CDN size |

### Amazon Games
| Item | Value |
|---|---|
| Auth | PKCE OAuth — no client secret required |
| GraphQL | `https://gaming.amazon.com/graphql` |
| Entitlements | `GetEntitlements` GraphQL query |
| Manifest format | Protobuf + XZ/LZMA compression |
| Launch config | `fuel.json` in game dir — configures `FuelPump` env vars |
| Required DLLs | `FuelSDK_x64.dll` + `AmazonGamesSDK_*.dll` deployed to game dir by `AmazonSdkManager` |

---

## 9. Lessons Learned During Integration

### Lesson 1 — ID collision with MaterialComponents
**Problem:** IDs `0x7f09027f–0x7f090281` (immediately after `main_menu_toggle_fullscreen` = `0x7f09027e`) are occupied by MaterialComponents: `masked`, `material_clock_display`, `material_clock_face`.  
**Fix:** Use the 3 slots after the last entry in `public.xml` (`zero_corner_chip` = `0x7f0903a5`) → IDs `0x7f0903a6`, `0x7f0903a7`, `0x7f0903a8`.  
**Rule:** Always grep `R$id.smali` and `public.xml` for the highest existing ID before choosing new ones.

### Lesson 2 — Register v2 is poisoned in onNavigationItemSelected
**Problem:** The method sets `v2 = 0x1` (boolean true) near the top as its return value. Any handler block that writes a class reference into `v2` causes `VerifyError: register v2 has type IntegerConstant but expected Boolean` at install time.  
**Fix:** Use `v3` (or higher) as scratch in all injected handler blocks.  
**Rule:** Inspect the method prologue for early register assignments before choosing scratch registers in smali patches.

### Lesson 3 — ab_*.png are not real PNGs
**Problem:** Star has animation frames stored as `ab_0001.png` through `ab_N.png`, plus `ab_gear_0001.png` through `ab_gear_N.png` and `ab_quilt_0001.png` through `ab_quilt_N.png` in `res/drawable/`. These are binary animation data — aapt2 rejects them: _"failed to read PNG signature"_.  
**Fix:** Delete all `ab_*.png` and `animated_background.xml` before `apktool b`; strip their `public.xml` entries; re-inject originals from the base APK via `unzip`+`zip` after rebuild.  
**Rule:** Broaden the `sed` strip pattern to `name="ab_` (not `name="ab_[0-9]`) to catch all three variant prefixes.

### Lesson 4 — public.xml must be merged, not replaced
**Problem:** Replacing `apktool_out/res/values/public.xml` (4856 lines, all AppCompat/Material/AndroidX IDs pinned) with a 3-entry patch file causes aapt2 to reassign every internal resource ID. The compiled DEX code still references the original IDs, so drawables fail to load, themes break, and the app crashes with `IllegalStateException: VectorDrawableCompat` on launch.  
**Fix:** Use `sed` to inject the 3 new entries into the existing `public.xml` instead of replacing it.  
**Rule:** Never replace `public.xml` entirely in an apktool patch workflow. Always merge.

### Lesson 5 — VectorDrawableCompat needs explicit initialization
**Problem:** The original APK was compiled with Gradle's `vectorDrawables.useSupportLibrary = true`. This configuration is a build-time flag — apktool's rebuild does not preserve it. AppCompat's `checkVectorDrawableSetup()` verifies it at runtime by trying to load `abc_vector_test` drawable as a `VectorDrawable`. After apktool rebuild, the ID lookup succeeds but the drawable type check fails → crash on every launch.  
**Fix:** Call `AppCompatDelegate.setCompatVectorFromResourcesEnabled(true)` before `super.onCreate()` in `MainActivity`.  
**Rule:** Any apktool rebuild of an AppCompat app that uses vector drawables requires this smali call. It must precede `super.onCreate()`.

### Lesson 6 — GITHUB_TOKEN needs explicit write permission
**Problem:** The default Actions `GITHUB_TOKEN` has `Contents: read`. `gh release create` fails with 403.  
**Fix:** Add `permissions: contents: write` to the job block.

### Lesson 7 — sparse-switch vs packed-switch
Star uses `sparse-switch` (unlike REF4IK which uses `packed-switch`). Sparse-switch is simpler to extend — just add `0xID -> :label` lines anywhere in the table. No base-value arithmetic, no gap-filling.

### Lesson 8 — DEX slot selection
Star has 16 DEX files (`classes.dex` through `classes16.dex`). `classes17.dex` is the first free slot. It must be injected via `zip -j` after `apktool b` runs — apktool has no smali to generate it from.

---

## 10. Device Test Results

| Activity | Launch time | CI run | Status |
|---|---|---|---|
| `MainActivity` | — | 24295767143 | ✅ |
| `GogMainActivity` | 35ms | 24295767143 | ✅ |
| `GogLoginActivity` | 250ms | 24295767143 | ✅ |
| `GogGamesActivity` | 33ms | 24295767143 | ✅ |
| `EpicMainActivity` | 34ms | 24295767143 | ✅ |
| `EpicLoginActivity` | 135ms | 24295767143 | ✅ |
| `EpicGamesActivity` | 32ms | 24295767143 | ✅ |
| `AmazonMainActivity` | 31ms | 24295767143 | ✅ |
| `AmazonLoginActivity` | 36ms | 24295767143 | ✅ |
| `AmazonGamesActivity` | 27ms | 24295767143 | ✅ |

No `FATAL EXCEPTION` or `AndroidRuntime` errors in any tested session.

---

## 11. Source Code Integration Guide (For the Star Developer)

This section explains how to integrate the GOG, Epic, and Amazon stores **natively** using the original Star source code and Gradle — the clean alternative to the APK mod approach above.

The APK mod approach works but has inherent limitations: it is fragile to base APK updates, requires apktool round-trips, and cannot be part of the normal release build. With source access, the integration becomes a first-class feature of the app.

---

### 11.1 Add the store module to your project

Create a new module or place the Java files directly in your app module. The store files belong in:

```
app/src/main/java/com/winlator/cmod/store/
```

Copy all 29 `.java` files from this repo's `extension/` directory into that path. No renaming needed — the package declaration `com.winlator.cmod.store` already matches.

---

### 11.2 Add Gradle dependencies

In `app/build.gradle`:

```groovy
android {
    defaultConfig {
        vectorDrawables {
            useSupportLibrary true   // Required for AppCompat vector drawables
        }
    }
}

dependencies {
    // Already present in Star — verify these are included:
    implementation 'androidx.appcompat:appcompat:1.x.x'
    implementation 'androidx.preference:preference:1.x.x'

    // Add for store integration:
    implementation 'org.json:json:20240303'
    implementation 'org.apache.commons:commons-compress:1.26.0'
}
```

> **Note on `vectorDrawables.useSupportLibrary = true`:** This is what the APK mod re-adds manually via smali. In a Gradle build it is set here and requires no smali patch.

---

### 11.3 Replace LudashiLaunchBridge with direct API calls

`LudashiLaunchBridge.java` uses Java reflection to call `ContainerManager` because the APK mod has no access to the compiled Winlator classes at build time. With source access, call directly:

```java
// Replace the reflection-based bridge with direct calls:
import com.winlator.cmod.container.Container;
import com.winlator.cmod.container.ContainerManager;

// In your GogLaunchHelper / EpicLaunchHelper / AmazonLaunchHelper:
ContainerManager cm = new ContainerManager(context);
List<Container> containers = cm.getContainers();

// Show picker dialog...
Container selected = containers.get(chosenIndex);
File desktopDir = selected.getDesktopDir();

// Write .desktop shortcut:
File shortcut = new File(desktopDir, gameName + ".desktop");
String content = "[Desktop Entry]\n"
    + "Name=" + gameName + "\n"
    + "Exec=wine Z:\\\\" + relativeExePath + "\n"
    + "Icon=\n"
    + "Type=Application\n"
    + "StartupWMClass=explorer\n\n"
    + "[Extra Data]\n";
Files.write(shortcut.toPath(), content.getBytes());
```

You can delete `LudashiLaunchBridge.java` entirely once direct calls are in place.

---

### 11.4 Update AndroidManifest.xml

Add the 9 activity declarations inside `<application>`. These are identical to what the APK mod adds — no change needed:

```xml
<!-- GOG Game Store -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.GogGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>

<!-- Epic Games Store -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.EpicGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>

<!-- Amazon Games -->
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonMainActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonLoginActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
<activity android:exported="false"
    android:name="com.winlator.cmod.store.AmazonGamesActivity"
    android:screenOrientation="fullSensor"
    android:theme="@style/AppTheme"/>
```

---

### 11.5 Add menu items

In `res/menu/main_menu.xml`, add 3 items where you want them in the drawer order. The IDs can be any unused name — Gradle assigns them automatically, no hex pinning required:

```xml
<item android:icon="@drawable/icon_open"
      android:id="@+id/main_menu_gog"
      android:title="GOG" />
<item android:icon="@drawable/icon_open"
      android:id="@+id/main_menu_epic"
      android:title="Epic Games" />
<item android:icon="@drawable/icon_open"
      android:id="@+id/main_menu_amazon"
      android:title="Amazon Games" />
```

> Note: Use `@+id/` (not `@id/`) to let Gradle generate and assign the IDs. No need to pin anything in `public.xml`.

---

### 11.6 Update MainActivity

Find `onNavigationItemSelected()` in `MainActivity.java` (or `.kt`). Add 3 cases to the existing switch:

**Java:**
```java
@Override
public boolean onNavigationItemSelected(@NonNull MenuItem item) {
    int id = item.getItemId();

    // ... existing cases ...

    } else if (id == R.id.main_menu_gog) {
        startActivity(new Intent(this, GogMainActivity.class));
    } else if (id == R.id.main_menu_epic) {
        startActivity(new Intent(this, EpicMainActivity.class));
    } else if (id == R.id.main_menu_amazon) {
        startActivity(new Intent(this, AmazonMainActivity.class));
    }

    drawerLayout.closeDrawer(GravityCompat.START);
    return true;
}
```

**Kotlin:**
```kotlin
override fun onNavigationItemSelected(item: MenuItem): Boolean {
    when (item.itemId) {
        // ... existing cases ...
        R.id.main_menu_gog    -> startActivity(Intent(this, GogMainActivity::class.java))
        R.id.main_menu_epic   -> startActivity(Intent(this, EpicMainActivity::class.java))
        R.id.main_menu_amazon -> startActivity(Intent(this, AmazonMainActivity::class.java))
    }
    drawerLayout.closeDrawer(GravityCompat.START)
    return true
}
```

If the existing code uses `switch`/`when` on resource IDs, add the 3 new cases in the same block.

---

### 11.7 No other files need changing

| APK mod required | Source build equivalent |
|---|---|
| smali patch for `setCompatVectorFromResourcesEnabled` | `vectorDrawables.useSupportLibrary true` in `build.gradle` |
| hex ID pinning in `public.xml` | Not needed — Gradle assigns IDs automatically |
| `@id/` in menu XML | `@+id/` — Gradle generates the ID |
| `R$id.smali` field constants | Not needed — `R.id.main_menu_gog` is generated by Gradle |
| `classes17.dex` injection | Not needed — classes compile into the main DEX by Gradle |
| ab_*.png strip/reinject workaround | Not needed — Gradle compiles resources correctly |
| `permissions: contents: write` in CI | Not needed — normal Gradle `assembleRelease` |

The only net additions to a source build are: the 29 Java files, 3 `build.gradle` dependency lines, 9 manifest activity declarations, 3 menu items, and 3 switch cases in `MainActivity`.

---

### 11.8 Signing

Replace `testkey.pk8` / `testkey.x509.pem` with your own release keystore. In `build.gradle`:

```groovy
android {
    signingConfigs {
        release {
            storeFile     file("your-release-key.jks")
            storePassword System.getenv("STORE_PASSWORD")
            keyAlias      "your-key-alias"
            keyPassword   System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
        }
    }
}
```

Store credentials as GitHub Actions secrets, not in the repository.

---

### 11.9 Summary — what the source integration looks like end-to-end

```
1. Copy extension/*.java → app/src/main/java/com/winlator/cmod/store/
2. Add org.json + commons-compress to build.gradle dependencies
3. Add vectorDrawables.useSupportLibrary = true to build.gradle
4. Replace LudashiLaunchBridge calls with direct ContainerManager calls
5. Add 9 <activity> entries to AndroidManifest.xml
6. Add 3 <item> entries to res/menu/main_menu.xml
7. Add 3 cases to MainActivity.onNavigationItemSelected()
8. Build normally: ./gradlew assembleRelease
```

That is the complete integration — roughly 30 minutes of work with source access, producing a clean build with no APK surgery required.

---

## 12. File Touch Map

| File | DEX / Location | Role | Touch type |
|---|---|---|---|
| `smali_classes8/com/winlator/cmod/MainActivity.smali` | classes8 | Nav dispatch | **Patched** |
| `smali_classes2/com/winlator/cmod/R$id.smali` | classes2 | Resource IDs | **Patched** |
| `res/menu/main_menu.xml` | res | Nav drawer menu | **Replaced** |
| `res/values/public.xml` | res | Resource ID pins | **Merged (sed)** |
| `AndroidManifest.xml` | root | Activity registry | **Replaced** |
| `extension/*.java` (29 files) | → classes17.dex | All store code | **Added** |
| `.github/workflows/build.yml` | CI | Build pipeline | **Added** |
| `testkey.pk8` / `testkey.x509.pem` | root | Signing keys | **Added** |
| `smali_classes14/com/winlator/cmod/container/Container.smali` | classes14 | Container API | Read-only (analysed) |
| `smali_classes14/com/winlator/cmod/container/ContainerManager.smali` | classes14 | Container CRUD | Read-only (analysed) |
| `smali_classes12/com/winlator/cmod/xenvironment/ImageFs.smali` | classes12 | Z: drive source | Read-only (analysed) |
| `smali_classes8/com/winlator/cmod/ShortcutsFragment.smali` | classes8 | Shortcut loader | Read-only (analysed) |

---

*Report version: 3.1 — 2026-04-12 (v1.0.0 stable released, all phases complete)*  
*Integration repo: https://github.com/The412Banner/star-test*  
*Reference builds: Ludashi-plus · REF4IK-Banner*
