# Star Bionic — Full Reverse Engineering & Store Integration Report

**Prepared by:** The412Banner / BannerHub Team  
**Date:** 2026-04-11  
**APK:** `star-Bionic_original.apk`  
**GitHub Repo:** https://github.com/The412Banner/star-test  
**Reference implementations:** Ludashi-plus · REF4IK-Banner  
**Purpose:** Full architectural map of Star Bionic V1.0 + exact injection blueprint for GOG, Epic Games, and Amazon Games store integrations

---

## Implementation Status

| Task | Status | Notes |
|---|---|---|
| Repo created | ✅ Done | https://github.com/The412Banner/star-test |
| Base APK uploaded to `base-apk` release | ✅ Done | `star-Bionic_original.apk` (547MB) |
| 28 extension Java files copied to `extension/` | ✅ Done | From Ludashi-plus |
| `testkey.pk8` / `testkey.x509.pem` added | ✅ Done | AOSP testkey |
| `patches/smali_classes8/.../MainActivity.smali` — sparse-switch + 3 handlers | ✅ Done | IDs `0x7f0903a6/a7/a8`, using `v3` scratch |
| `patches/smali_classes2/.../R$id.smali` — 3 field constants | ✅ Done | IDs corrected from initial plan |
| `patches/res/menu/main_menu.xml` — 3 store items | ✅ Done | GOG, Epic Games, Amazon Games |
| `patches/res/values/public.xml` — 3 ID pins | ✅ Done | Avoids aapt2 reassignment |
| `patches/AndroidManifest.xml` — 9 activity declarations | ✅ Done | `fullSensor` orientation |
| `.github/workflows/build.yml` — full CI pipeline | ✅ Done | javac + d8 → classes17.dex inject |
| First CI build v1 | ❌ Failed | ab_*.png pseudo-PNG issue (same as Ludashi-plus) |
| Fix: ab_*.png strip + re-inject in build.yml | ✅ Done | 117 files, animated_background.xml |
| First CI build v2 | ⏳ Pending | Tag v1.0.0-pre (retag) |
| Functional test — GOG | ⏳ Pending | |
| Functional test — Epic | ⏳ Pending | |
| Functional test — Amazon | ⏳ Pending | |
| Stable release | ⏳ Pending | |

---

## Executive Summary

Star Bionic is a **Winlator Bionic** build sharing the exact same Java source package (`com.winlator.cmod.*`) as Ludashi-plus and REF4IK-Banner. This means the **28 Java extension files** already written and proven in those projects transfer directly to Star — zero rewrites required. Only three surgical changes to the existing smali/resources are needed to wire the stores into the navigation drawer, plus a CI workflow to compile and inject the new DEX on every build.

**Effort estimate:** ~2–3 hours of implementation + one CI iteration.

---

## 1. APK Identity

| Field | Value |
|---|---|
| Package name (manifest) | `com.winlator.star` |
| Source package | `com.winlator.cmod.*` (same as Ludashi-plus & REF4IK) |
| App version | `Bionic V1.0` |
| Version code | `20` |
| Min SDK | 26 (Android 8.0) |
| Target SDK | 28 (Android 9) |
| APK size | ~547 MB (includes bundled Wine, Proton, imagefs) |
| DEX count | 16 (classes.dex → classes16.dex) |
| Decompile tool | apktool 2.9.3 |

---

## 2. Architecture Overview

```
Android Navigation Drawer (MainActivity)
    ↓ menu item selected
    startActivity(StoreActivity)          ← injection point
    ↓ user browses / downloads game
    LudashiLaunchBridge.addToLauncher()  ← reflection, no stubs needed
    ↓ container picker dialog
    .desktop file → container Desktop dir
    ↓
ShortcutsFragment picks it up automatically
    ↓ user taps shortcut
XServerDisplayActivity → Wine → FEXCore/Box64 → game.exe
```

---

## 3. Navigation Structure

**File:** `apktool_out/res/menu/main_menu.xml`  
**Dispatch:** `MainActivity.onNavigationItemSelected()` in `smali_classes8/com/winlator/cmod/MainActivity.smali` line 1413, using a **`sparse-switch`** at line 1445.

### Current menu items & IDs

| ID name | Hex value | Fragment launched |
|---|---|---|
| `main_menu_about` | `0x7f090269` | `showAboutDialog()` |
| `main_menu_adrenotools_gpu_drivers` | `0x7f09026b` | `AdrenotoolsFragment` |
| `main_menu_containers` | `0x7f09026c` | `ContainersFragment` |
| `main_menu_contents` | `0x7f09026d` | `ContentsFragment` |
| `main_menu_input_controls` | `0x7f090271` | `InputControlsFragment` |
| `main_menu_saves` | `0x7f090279` | `SavesFragment` |
| `main_menu_settings` | `0x7f09027b` | `SettingsFragment` |
| `main_menu_shortcuts` | `0x7f09027c` | `ShortcutsFragment` |
| `main_menu_task_manager` | `0x7f09027d` | (runtime menu, not drawer) |
| `main_menu_toggle_fullscreen` | `0x7f09027e` | (runtime menu, not drawer) |

**Highest used ID: `0x7f09027e`**. New store IDs use the next 3 slots.

### New store menu IDs

| ID name | Hex value | Activity |
|---|---|---|
| `main_menu_gog` | `0x7f0903a6` | `GogMainActivity` |
| `main_menu_epic` | `0x7f0903a7` | `EpicMainActivity` |
| `main_menu_amazon` | `0x7f0903a8` | `AmazonMainActivity` |

> **ID conflict note:** IDs `0x7f09027f–0x7f090281` were originally planned but are taken by MaterialComponents (`masked`, `material_clock_display`, `material_clock_face`). The last free slot after `public.xml`'s final entry (`zero_corner_chip` at `0x7f0903a5`) was used instead.

---

## 4. Container & Shortcut System

### Container class: `com.winlator.cmod.container.Container`
**DEX:** `smali_classes14`

| Method | Returns | Description |
|---|---|---|
| `getRootDir()` | `File` | Base directory of this Wine prefix |
| `getDesktopDir()` | `File` | `rootDir/.wine/drive_c/users/xuser/Desktop/` |
| `getDrives()` | `String` | Drive letter mappings |
| `getName()` | `String` | Display name |

**Default drives:**
- `F:` → `/sdcard` (external storage)
- `D:` → `/sdcard/Download`
- `Z:` → imagefs root (`context.getFilesDir()/imagefs/`) — confirmed by `ShortcutsFragment.smali` line 851–863

### Shortcut format (.desktop file)

Written to `container.getDesktopDir()/<gameName>.desktop`:

```ini
[Desktop Entry]
Name=Game Name
Exec=wine Z:\\gog_games\\GameDir\\game.exe
Icon=
Type=Application
StartupWMClass=explorer

[Extra Data]
```

`ContainerManager.loadShortcuts()` automatically scans all container Desktop dirs on next load. No additional code needed to make the shortcut appear in the Shortcuts tab.

### LudashiLaunchBridge — reflection-based container picker

The `LudashiLaunchBridge.java` file (already in `Ludashi-plus/extension/`) uses **Java reflection** to call `ContainerManager` — so it compiles against `android.jar` alone, with no Winlator stubs. It:
1. Instantiates `ContainerManager` via reflection
2. Calls `getContainers()` → list of all user containers
3. Shows `AlertDialog` with container names
4. On selection: calls `getDesktopDir()` → writes `.desktop` file

**This file works on Star unchanged.** The source package `com.winlator.cmod.container.ContainerManager` is present in `smali_classes14` and has the same API.

---

## 5. Install Path Strategy

Games install under `imagefs/` so Wine's `Z:` drive can reach them directly:

| Store | Android path | Wine path |
|---|---|---|
| GOG | `{filesDir}/imagefs/gog_games/{gameDir}/` | `Z:\gog_games\{gameDir}\game.exe` |
| Epic | `{filesDir}/imagefs/epic_games/{gameDir}/` | `Z:\epic_games\{gameDir}\game.exe` |
| Amazon | `{filesDir}/imagefs/amazon_games/{gameDir}/` | `Z:\amazon_games\{gameDir}\game.exe` |

`GogInstallPath.getInstallDir(ctx, name)` calls `ctx.getFilesDir()` which returns the Star-specific data dir (`com.winlator.star`) automatically at runtime. No code change required.

---

## 6. Extension Files — Full Reusability Matrix

All 28 Java files from `Ludashi-plus/extension/` are in package `com.winlator.cmod.store`. They compile against `android.jar` alone (reflection for Winlator calls). **Zero rewrites needed for Star.**

| File | Size | Reuse | Notes |
|---|---|---|---|
| `GogGame.java` | 795B | ✅ Direct | POJO model |
| `GogInstallPath.java` | 1.2KB | ✅ Direct | Path helper — uses `ctx.getFilesDir()` |
| `GogLaunchHelper.java` | 400B | ✅ Direct | Wrapper over LudashiLaunchBridge |
| `GogTokenRefresh.java` | 3.1KB | ✅ Direct | Pure HTTP token refresh |
| `GogDownloadManager.java` | 64KB | ✅ Direct | Full GOG API + parallel download engine |
| `GogLoginActivity.java` | 7.2KB | ✅ Direct | WebView OAuth login |
| `GogMainActivity.java` | 6.7KB | ✅ Direct | Entry-point Activity |
| `GogGamesActivity.java` | 66KB | ✅ Direct | Library list + download UI |
| `EpicGame.java` | 1.6KB | ✅ Direct | POJO model |
| `EpicCredentialStore.java` | 3.8KB | ✅ Direct | SharedPreferences wrapper |
| `EpicAuthClient.java` | 9.6KB | ✅ Direct | Pure HTTP auth |
| `EpicApiClient.java` | 11.7KB | ✅ Direct | Pure HTTP API |
| `EpicDownloadManager.java` | 45KB | ✅ Direct | Chunked download engine |
| `EpicLoginActivity.java` | 5.4KB | ✅ Direct | WebView OAuth |
| `EpicMainActivity.java` | 5.8KB | ✅ Direct | Entry-point Activity |
| `EpicGamesActivity.java` | 56KB | ✅ Direct | Library list + download UI |
| `AmazonGame.java` | 1.5KB | ✅ Direct | POJO model |
| `AmazonCredentialStore.java` | 4.9KB | ✅ Direct | SharedPreferences wrapper |
| `AmazonPKCEGenerator.java` | 2.7KB | ✅ Direct | PKCE generator |
| `AmazonAuthClient.java` | 9.8KB | ✅ Direct | PKCE device registration |
| `AmazonApiClient.java` | 13KB | ✅ Direct | GetEntitlements + manifest |
| `AmazonManifest.java` | 12.8KB | ✅ Direct | Protobuf manifest parser |
| `AmazonDownloadManager.java` | 18.7KB | ✅ Direct | Parallel download + XZ/LZMA |
| `AmazonSdkManager.java` | 10.4KB | ✅ Direct | FuelSDK DLL deployment |
| `AmazonLaunchHelper.java` | 11.2KB | ✅ Direct | fuel.json launch env |
| `AmazonLoginActivity.java` | 7.2KB | ✅ Direct | PKCE WebView login |
| `AmazonMainActivity.java` | 6.8KB | ✅ Direct | Entry-point Activity |
| `AmazonGamesActivity.java` | 56.5KB | ✅ Direct | Library list + download UI |
| `LudashiLaunchBridge.java` | 5.7KB | ✅ Direct | Container picker + .desktop writer |

**Dependencies needed at compile time:**
- `org.json` JAR — `https://repo1.maven.org/maven2/org/json/json/20240303/json-20240303.jar`
- `commons-compress` JAR (Amazon LZMA) — `https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar`

---

## 7. DEX Strategy

| DEX slot | Current contents | Status |
|---|---|---|
| classes (DEX 1) | androidx, kotlin stdlib, OkHttp, etc. | ~54,340 methods — **full** |
| classes2 | R$* resource refs | Available |
| classes3–7 | small fexcore/audio/box64 packages | Available |
| classes8 | main app fragments + activities | ~1,515 methods |
| classes9–16 | container, xenvironment, renderer, bigpicture, etc. | Occupied |
| **classes17** | **→ NEW: store extension** | **First free slot** |

All 28 extension Java files + `org.json` + `commons-compress` compile to approximately **~2,500 methods** total — well under the 65,535 DEX limit. One new `classes17.dex` is sufficient.

**No existing DEX is modified.** Zero risk of hitting method limits in existing DEX files.

---

## 8. Exact Smali Patch Targets

### 8.1 MainActivity — sparse-switch extension

**File:** `patches/smali_classes8/com/winlator/cmod/MainActivity.smali`  
**Method:** `onNavigationItemSelected` — starts at line 1413  
**Switch table:** line 1539, `.sparse-switch` format

**Current sparse-switch (lines 1539–1548):**
```smali
:sswitch_data_0
.sparse-switch
    0x7f090269 -> :sswitch_7   # about
    0x7f09026b -> :sswitch_6   # adrenotools
    0x7f09026c -> :sswitch_5   # containers
    0x7f09026d -> :sswitch_4   # contents
    0x7f090271 -> :sswitch_3   # input_controls
    0x7f090279 -> :sswitch_2   # saves
    0x7f09027b -> :sswitch_1   # settings
    0x7f09027c -> :sswitch_0   # shortcuts
.end sparse-switch
```

**Patched sparse-switch (add 3 entries):**
```smali
:sswitch_data_0
.sparse-switch
    0x7f090269 -> :sswitch_7   # about
    0x7f09026b -> :sswitch_6   # adrenotools
    0x7f09026c -> :sswitch_5   # containers
    0x7f09026d -> :sswitch_4   # contents
    0x7f090271 -> :sswitch_3   # input_controls
    0x7f090279 -> :sswitch_2   # saves
    0x7f09027b -> :sswitch_1   # settings
    0x7f09027c -> :sswitch_0   # shortcuts
    0x7f0903a6 -> :sswitch_8   # GOG    ← NEW
    0x7f0903a7 -> :sswitch_9   # Epic   ← NEW
    0x7f0903a8 -> :sswitch_a   # Amazon ← NEW
.end sparse-switch
```

**New handler blocks** (insert before `:sswitch_data_0`):
```smali
    :sswitch_8
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/GogMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0

    :sswitch_9
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/EpicMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0

    :sswitch_a
    new-instance v1, Landroid/content/Intent;
    const-class v3, Lcom/winlator/cmod/store/AmazonMainActivity;
    invoke-direct {v1, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {p0, v1}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V
    goto :goto_0
```

> **Register note (from REF4IK lesson):** Use `v3` as scratch — NOT `v2`. The method sets `v2 = 0x1` (boolean true) early as a return value. Clobbering `v2` with a Class reference causes a `VerifyError` at install time. `v3` is safe (confirmed from the existing `sswitch_7`/about handler pattern).

### 8.2 R$id.smali — 3 new field constants

**File:** `patches/smali_classes2/com/winlator/cmod/R$id.smali`

Add after the `main_menu_toggle_fullscreen` line:
```smali
.field public static final main_menu_gog:I = 0x7f0903a6
.field public static final main_menu_epic:I = 0x7f0903a7
.field public static final main_menu_amazon:I = 0x7f0903a8
```

### 8.3 Summary of all patch files

| File | Location | Change |
|---|---|---|
| `MainActivity.smali` | `patches/smali_classes8/com/winlator/cmod/` | Add 3 sswitch entries + 3 handler blocks |
| `R$id.smali` | `patches/smali_classes2/com/winlator/cmod/` | Add 3 field constants |
| `main_menu.xml` | `patches/res/menu/` | Add 3 `<item>` elements |
| `public.xml` | `patches/res/values/` | Add 3 ID pins |
| `AndroidManifest.xml` | `patches/` | Add 9 `<activity>` declarations |

---

## 9. Manifest Additions

Add inside the `<application>` block:

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

## 10. Menu Resource Changes

### `patches/res/menu/main_menu.xml`

Add 3 items after `main_menu_shortcuts`:

```xml
<item android:icon="@drawable/icon_open"
    android:id="@id/main_menu_gog"
    android:title="GOG" />
<item android:icon="@drawable/icon_open"
    android:id="@id/main_menu_epic"
    android:title="Epic Games" />
<item android:icon="@drawable/icon_open"
    android:id="@id/main_menu_amazon"
    android:title="Amazon Games" />
```

### `patches/res/values/public.xml`

Add to the `id` type section (pins hex values so aapt2 doesn't reassign them):

```xml
<public type="id" name="main_menu_gog" id="0x7f0903a6" />
<public type="id" name="main_menu_epic" id="0x7f0903a7" />
<public type="id" name="main_menu_amazon" id="0x7f0903a8" />
```

---

## 11. CI Build Workflow (build.yml)

Full workflow from scratch (Star has no existing CI):

```yaml
name: Build Star Bionic + Store Integration

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Java 11
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: '11'

      - name: Install apktool
        run: |
          wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O apktool.jar
          echo '#!/bin/sh' > apktool && echo 'java -jar /usr/local/bin/apktool.jar "$@"' >> apktool
          chmod +x apktool && sudo mv apktool /usr/local/bin/apktool
          sudo mv apktool.jar /usr/local/bin/apktool.jar

      - name: Download base APK
        run: |
          gh release download base-apk --pattern "*.apk" --output base.apk
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Decompile APK
        run: apktool d base.apk -o apktool_out -f

      - name: Apply patches
        run: |
          cp -r patches/* apktool_out/

      - name: Download org.json dependency
        run: |
          wget -q "https://repo1.maven.org/maven2/org/json/json/20240303/json-20240303.jar" -O org-json.jar

      - name: Download commons-compress (Amazon LZMA)
        run: |
          wget -q "https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar" -O commons-compress.jar

      - name: Compile store extension → classes17.dex
        run: |
          ANDROID_JAR=$(ls $ANDROID_SDK_ROOT/platforms/android-*/android.jar | sort -V | tail -1)
          echo "android.jar: $ANDROID_JAR"
          mkdir -p ext_classes
          javac -source 8 -target 8 \
            -cp "$ANDROID_JAR:org-json.jar:commons-compress.jar" \
            -d ext_classes extension/*.java
          echo "Compiled $(find ext_classes -name '*.class' | wc -l) class files"
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          mkdir -p ext_dex
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/d8 \
            --release --min-api 26 --output ext_dex \
            $(find ext_classes -name '*.class') \
            org-json.jar commons-compress.jar

      - name: Rebuild APK
        run: apktool b apktool_out -o rebuilt-unsigned.apk

      - name: Inject classes17.dex
        run: |
          cp ext_dex/classes.dex classes17.dex
          zip -j rebuilt-unsigned.apk classes17.dex
          echo "classes17.dex injected: $(du -sh classes17.dex | cut -f1)"

      - name: Zipalign
        run: |
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/zipalign -p -f 4 rebuilt-unsigned.apk aligned.apk

      - name: Sign APK
        run: |
          BUILD_TOOLS=$(ls $ANDROID_SDK_ROOT/build-tools | sort -V | tail -1)
          $ANDROID_SDK_ROOT/build-tools/$BUILD_TOOLS/apksigner sign \
            --key testkey.pk8 --cert testkey.x509.pem \
            --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
            --out star-signed-${{ github.ref_name }}.apk aligned.apk

      - name: Upload release
        run: |
          gh release create ${{ github.ref_name }} \
            star-signed-${{ github.ref_name }}.apk \
            --title "Star Bionic ${{ github.ref_name }}" \
            --prerelease
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 12. Key API Constants

### GOG
- Auth URL: `https://auth.gog.com/auth?client_id=46899977096215655&redirect_uri=https://embed.gog.com/on_login_success?origin=client&response_type=code`
- Token URL: `https://auth.gog.com/token`
- Client ID: `46899977096215655` (public)
- Client secret: `9d85c43b1482497dbbce61f6e4aa173a433796eeae2ca8c5f6129f2dc4de46d9` (public)
- Library API: `https://embed.gog.com/account/getFilteredProducts?mediaType=1`
- Build API: `https://content-system.gog.com/products/{gameId}/os/windows/builds?generation=2`
- **Old game fallback:** `https://api.gog.com/products/{id}?expand=downloads` → direct `.exe` link

### Epic Games
- Auth: WebView → navigate to Epic login, redirect to `https://www.epicgames.com/id/api/redirect`
- Read auth code: `evaluateJavascript("document.body.innerText")` in `onPageFinished` → parse `authorizationCode` JSON field
- Library: `https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/public/assets/v2/`
- CDN preference: Fastly (`egdownload.fastly-edge.com`) → Akamai → Cloudflare (last resort)
- Chunk group subfolder: **DECIMAL** `"%02d".format(groupNum)` — not hex
- `ChunkFilesizeList` values: **hex strings** — parse with `Long.parseLong(s, 16)`

### Amazon Games
- Auth: PKCE OAuth — no client secret
- GetEntitlements: `https://gaming.amazon.com/graphql`
- Manifest: protobuf format + XZ/LZMA compression
- SDK required: `FuelSDK_x64.dll` + `AmazonGamesSDK_*` deployed to game dir
- Launch: `fuel.json` in game dir configures `FuelPump` env vars

---

## 13. Critical Lessons From REF4IK/Ludashi

1. **ID conflict:** Always check `R$id.smali` for the highest existing `id`-type value before picking new IDs. Star's highest is `0x7f09027e` — new IDs start at `0x7f09027f`.

2. **Register `v2` is poisoned:** `onNavigationItemSelected` sets `v2 = 0x1` (boolean return) early in the method. ANY store handler that writes a class reference into `v2` will cause `VerifyError: register v2 has type IntegerConstant but expected Boolean`. Always use `v3` as scratch in injected blocks.

3. **sparse-switch vs packed-switch:** Star uses `sparse-switch` (unlike REF4IK which uses `packed-switch`). `sparse-switch` is simpler to extend — just add new `0xID -> :label` lines anywhere in the table. No gap entries needed, no base value arithmetic.

4. **DEX injection after apktool:** `apktool b` generates classes.dex through classes16.dex from the existing smali. `classes17.dex` must be injected via `zip -j` AFTER `apktool b` runs — apktool has no smali source to generate it from. Same pattern as REF4IK's `classes23.dex`.

5. **Pin IDs in public.xml:** Without `<public type="id" name="..." id="0x7f09027f"/>` entries, aapt2 may assign different hex values on rebuild, breaking the switch table. Always pin.

6. **LudashiLaunchBridge uses Context.getFilesDir():** Returns the correct data directory for whatever package is installed. Works on Star (`com.winlator.star`) without any code change.

7. **imagefs Z: mapping:** Confirmed in `ShortcutsFragment.smali` — any path containing `/imagefs/` is mapped to `Z:`. Games MUST be installed under `{filesDir}/imagefs/` to be reachable by Wine.

8. **ab_*.png are not real PNGs:** Star has 117 `ab_*.png` animation frames and `animated_background.xml` in `res/drawable/`. These are binary animation data — aapt2 rejects them with "failed to read PNG signature". Fix: delete them before `apktool b`, strip their `public.xml` entries, then re-inject the originals from the base APK via `unzip`+`zip` after rebuild. Identical to Ludashi-plus fix.

9. **screenOrientation:** Use `fullSensor` on all 9 store activities for auto-rotate support. Some REF4IK devices had lock issues with `sensorLandscape` alone on store Activities.

---

## 14. Notes for the Star Developer

### What this integration adds
Three new entries in the side navigation drawer:
- **GOG** — logs in via GOG OAuth, browses your GOG library, downloads games directly into the Wine filesystem, adds them to Shortcuts with one tap
- **Epic Games** — logs in via Epic OAuth WebView, browses your Epic library, handles chunked Unreal Engine manifests, downloads via public Fastly/Akamai CDNs
- **Amazon Games** — logs in via Amazon PKCE OAuth, fetches your Prime Gaming entitlements, downloads via Amazon's protobuf manifest system, deploys FuelSDK DLLs alongside the game

### What is NOT changed
- Wine runtime, FEXCore, Box64 — untouched
- Container creation/management — untouched
- All existing menus, shortcuts, settings — untouched
- APK signing key — uses same AOSP testkey as community Winlator builds

### Where games land
All downloaded games go inside the app's private storage at `{filesDir}/imagefs/{store}_games/{game}/`. They appear in Wine as `Z:\{store}_games\{game}\game.exe` and as native Winlator shortcuts in the Shortcuts menu.

### Source package
All store code lives in `com.winlator.cmod.store.*` — a clean new sub-package, no collision with existing app code.

### Build system
The CI compiles the 28 Java extension files and injects them as `classes17.dex` into the APK. No Gradle, no build.gradle changes, no NDK — just `javac` + `d8`.

---

## Appendix: File Map

| Path | DEX/Location | Description |
|---|---|---|
| `smali_classes8/com/winlator/cmod/MainActivity.smali` | classes8 | Nav dispatch — **1 patch** |
| `smali_classes2/com/winlator/cmod/R$id.smali` | classes2 | Resource IDs — **1 patch** |
| `smali_classes14/com/winlator/cmod/container/Container.smali` | classes14 | Container data model |
| `smali_classes14/com/winlator/cmod/container/ContainerManager.smali` | classes14 | Container CRUD + shortcut loader |
| `smali_classes14/com/winlator/cmod/container/Shortcut.smali` | classes14 | Shortcut model |
| `smali_classes12/com/winlator/cmod/xenvironment/ImageFs.smali` | classes12 | Linux rootfs (Z: drive) |
| `smali_classes8/com/winlator/cmod/ShortcutsFragment.smali` | classes8 | Shortcuts UI |
| `res/menu/main_menu.xml` | res | Nav drawer menu — **1 patch** |
| `res/values/public.xml` | res | Resource ID pins — **1 patch** |
| `AndroidManifest.xml` | root | Activity registry — **1 patch** |
| `extension/*.java` (28 files) | → classes17.dex | All store code |

---

*Report version: 2.0 — 2026-04-11*  
*Reference repos: Ludashi-plus (v2.9 Bionic) · REF4IK-Banner (v7.x Bionic)*  
*Repo: https://github.com/The412Banner/star-test*
