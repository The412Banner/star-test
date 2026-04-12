# Star Bionic — Store Integration Task List

**Project:** star-test  
**Repo:** https://github.com/The412Banner/star-test  
**Reference:** Ludashi-plus · REF4IK-Banner (both complete)

---

## Phase 1 — Repo Structure Setup

- [ ] **1.1** Create `extension/` directory and copy all 28 Java files from `~/Ludashi-plus/extension/` (excluding `steam/` subdirectory)
- [ ] **1.2** Create `patches/` directory structure:
  - `patches/smali_classes8/com/winlator/cmod/MainActivity.smali`
  - `patches/smali_classes2/com/winlator/cmod/R$id.smali`
  - `patches/res/menu/main_menu.xml`
  - `patches/res/values/public.xml`
  - `patches/AndroidManifest.xml`
- [ ] **1.3** Copy `testkey.pk8` and `testkey.x509.pem` into repo root (same AOSP testkey used in Ludashi-plus and REF4IK-Banner)

---

## Phase 2 — Smali Patches

- [ ] **2.1** **MainActivity.smali patch** — copy from `apktool_out/smali_classes8/com/winlator/cmod/MainActivity.smali`, add 3 entries to `sparse-switch` table:
  ```
  0x7f09027f -> :sswitch_8   # GOG
  0x7f090280 -> :sswitch_9   # Epic
  0x7f090281 -> :sswitch_a   # Amazon
  ```
  Add 3 handler blocks before `:sswitch_data_0` using `v3` as scratch (NOT `v2` — `v2` holds boolean return value)

- [ ] **2.2** **R$id.smali patch** — copy from `apktool_out/smali_classes2/com/winlator/cmod/R$id.smali`, add 3 fields after `main_menu_toggle_fullscreen`:
  ```smali
  .field public static final main_menu_gog:I = 0x7f09027f
  .field public static final main_menu_epic:I = 0x7f090280
  .field public static final main_menu_amazon:I = 0x7f090281
  ```

---

## Phase 3 — Resource Patches

- [ ] **3.1** **main_menu.xml** — copy from `apktool_out/res/menu/main_menu.xml`, add 3 items (GOG, Epic, Amazon) after `main_menu_shortcuts`

- [ ] **3.2** **public.xml** — create `patches/res/values/public.xml` with 3 pinned IDs:
  ```xml
  <public type="id" name="main_menu_gog" id="0x7f09027f" />
  <public type="id" name="main_menu_epic" id="0x7f090280" />
  <public type="id" name="main_menu_amazon" id="0x7f090281" />
  ```

- [ ] **3.3** **AndroidManifest.xml** — create `patches/AndroidManifest.xml` from `apktool_out/AndroidManifest.xml`, add 9 `<activity>` declarations (3 per store: Main, Login, Games) with `screenOrientation="fullSensor"`

---

## Phase 4 — CI Workflow

- [ ] **4.1** Create `.github/workflows/build.yml` with steps:
  1. Checkout
  2. Java 11 setup
  3. Install apktool 2.9.3
  4. Download base APK from `base-apk` release
  5. Decompile with apktool
  6. Apply patches
  7. Download `org.json` JAR
  8. Download `commons-compress` JAR
  9. Compile 28 Java files → `classes17.dex`
  10. Rebuild APK (`apktool b`)
  11. Inject `classes17.dex` (`zip -j`)
  12. Zipalign
  13. Sign (AOSP testkey, v1+v2+v3)
  14. Upload to GitHub release

- [ ] **4.2** Add `GITHUB_TOKEN` is available (default for Actions — no extra secret needed for same-repo releases)

---

## Phase 5 — First Build & Validation

- [ ] **5.1** Push first tag (`v1.0.0-pre`) to trigger CI
- [ ] **5.2** Verify CI compiles without errors — check for `javac` and `d8` success in logs
- [ ] **5.3** Verify `classes17.dex` is present in final APK: `unzip -l *.apk | grep classes17`
- [ ] **5.4** Install APK — confirm GOG, Epic, Amazon entries appear in side menu
- [ ] **5.5** Confirm no crash on tapping each store entry (Activities launch)

---

## Phase 6 — Functional Testing

- [ ] **6.1 GOG:** Login → library syncs → select game → Download → container picker appears → shortcut written → game appears in Shortcuts tab
- [ ] **6.2 Epic:** OAuth WebView login → `authorizationCode` extracted from redirect body → library syncs → chunked download → shortcut created
- [ ] **6.3 Amazon:** PKCE login → GetEntitlements → manifest proto download + XZ decompress → FuelSDK DLLs deployed → shortcut created
- [ ] **6.4** Verify each shortcut launches via `XServerDisplayActivity` (Wine boots, game starts)
- [ ] **6.5** Test on-device auto-rotate in all 9 store Activities (confirm `fullSensor` works)

---

## Phase 7 — Stable Release

- [ ] **7.1** Confirm all 3 stores functional end-to-end on device
- [ ] **7.2** Tag stable release (`v1.0.0`)
- [ ] **7.3** Set release description (warning block + what's new + installation guide)
- [ ] **7.4** Update `STAR_ANALYSIS_REPORT.md` with final confirmed implementation status
- [ ] **7.5** Share report with Star developer

---

## Key Reference Files

| Need | Look here |
|---|---|
| Extension Java source (28 files) | `~/Ludashi-plus/extension/` |
| Working MainActivity patch example | `~/REF4IK-Banner/patches/smali_classes8/` (REF4IK uses if-eq, Star uses sparse-switch — simpler) |
| Working menu XML example | `~/REF4IK-Banner/patches/res/menu/main_menu.xml` |
| Working manifest example | `~/REF4IK-Banner/patches/AndroidManifest.xml` |
| Working build.yml example | `~/REF4IK-Banner/.github/workflows/build.yml` |
| GOG API constants | `~/GOG_PIPELINE_REPORT.md` |
| Epic API constants | `~/EPIC_PIPELINE_REPORT.md` |
| Amazon API constants | `~/AMAZON_PIPELINE_REPORT.md` |
| Full Star architecture | `~/star/STAR_ANALYSIS_REPORT.md` |

---

## ID Quick Reference

| ID name | Hex | Purpose |
|---|---|---|
| `main_menu_gog` | `0x7f09027f` | sparse-switch entry + R$id field + menu item + public.xml pin |
| `main_menu_epic` | `0x7f090280` | sparse-switch entry + R$id field + menu item + public.xml pin |
| `main_menu_amazon` | `0x7f090281` | sparse-switch entry + R$id field + menu item + public.xml pin |

---

## Total File Changes

| Category | Count |
|---|---|
| Extension Java files to copy | 28 |
| Smali patches | 2 |
| Resource patches | 3 |
| New DEX | 1 (classes17.dex) |
| CI workflow | 1 |
| New manifest `<activity>` blocks | 9 |
| New menu items | 3 |
| **Total new/modified files** | **~37** |
