# Star Bionic — Store Integration Task List

**Project:** star-test  
**Repo:** https://github.com/The412Banner/star-test  
**Reference:** Ludashi-plus · REF4IK-Banner (both complete)

---

## Phase 1 — Repo Structure Setup ✅

- [x] **1.1** Create `extension/` directory and copy all 29 Java files from `~/Ludashi-plus/extension/` (excluding `steam/` subdirectory) — 29 files confirmed
- [x] **1.2** Create `patches/` directory structure:
  - `patches/smali_classes8/com/winlator/cmod/MainActivity.smali`
  - `patches/smali_classes2/com/winlator/cmod/R$id.smali`
  - `patches/res/menu/main_menu.xml`
  - `patches/res/values/public.xml`
  - `patches/AndroidManifest.xml`
- [x] **1.3** Copy `testkey.pk8` and `testkey.x509.pem` into repo root (same AOSP testkey used in Ludashi-plus and REF4IK-Banner)

---

## Phase 2 — Smali Patches ✅

- [x] **2.1** **MainActivity.smali patch** — sparse-switch extended with 3 new entries:
  ```
  0x7f0903a6 -> :sswitch_8   # GOG
  0x7f0903a7 -> :sswitch_9   # Epic
  0x7f0903a8 -> :sswitch_a   # Amazon
  ```
  Handler blocks added before `:sswitch_data_0` using `v3` as scratch (NOT `v2` — `v2` holds boolean return value)

- [x] **2.2** **R$id.smali patch** — 3 fields added after `main_menu_toggle_fullscreen` (0x7f09027e):
  ```smali
  .field public static final main_menu_gog:I = 0x7f0903a6
  .field public static final main_menu_epic:I = 0x7f0903a7
  .field public static final main_menu_amazon:I = 0x7f0903a8
  ```

---

## Phase 3 — Resource Patches ✅

- [x] **3.1** **main_menu.xml** — 3 store items added (GOG, Epic Games, Amazon Games) after `main_menu_shortcuts` using `@drawable/icon_open`

- [x] **3.2** **public.xml** — 3 IDs pinned (after `zero_corner_chip` = 0x7f0903a5, not the colliding 0x7f09027f–81 range):
  ```xml
  <public type="id" name="main_menu_gog" id="0x7f0903a6" />
  <public type="id" name="main_menu_epic" id="0x7f0903a7" />
  <public type="id" name="main_menu_amazon" id="0x7f0903a8" />
  ```

- [x] **3.3** **AndroidManifest.xml** — 9 `<activity>` declarations added (3 per store: Main, Login, Games) with `screenOrientation="fullSensor"`

---

## Phase 4 — CI Workflow ✅

- [x] **4.1** Create `.github/workflows/build.yml` — all 17 steps implemented:
  1. Checkout
  2. Java 11 setup
  3. Install apktool 2.9.3
  4. Download base APK from `base-apk` release
  5. Decompile with apktool
  6. Apply patches (`cp -r patches/* apktool_out/`)
  7. Remove `ab_*.png` pseudo-PNG files before aapt2
  8. Download `org.json` JAR
  9. Download `commons-compress` JAR
  10. Compile 29 Java files → `classes17.dex` (javac + d8)
  11. Rebuild APK (`apktool b`)
  12. Re-inject `ab_*.png` + `animated_background.xml` from base APK
  13. Inject `classes17.dex` (`zip -j`)
  14. Zipalign
  15. Sign (AOSP testkey, v1+v2+v3)
  16. Upload to GitHub release

- [x] **4.2** `permissions: contents: write` added to job block (required for `gh release create`)

---

## Phase 5 — First Build & Validation

- [x] **5.1** Push first tag (`v1.0.0-pre`) — CI triggered
- [x] **5.2** CI run 24295336304 ✅ — all steps green; 71 class files compiled; `classes17.dex` 1.2M built
- [x] **5.3** `classes17.dex` confirmed present in APK (1,212,264 bytes, CI log verified)
- [x] **5.4** Install APK — GOG, Epic, Amazon entries confirmed in nav drawer ✅
- [x] **5.5** No crash — GogMainActivity (35ms), GogLoginActivity (250ms), GogGamesActivity (33ms) all launched cleanly ✅

---

## Phase 6 — Functional Testing

- [x] **6.1 GOG:** GogMainActivity, GogLoginActivity, GogGamesActivity all launch ✅ (confirmed 2026-04-11)
- [x] **6.2 Epic:** EpicMainActivity (34ms), EpicLoginActivity (135ms), EpicGamesActivity (32ms) all launch ✅
- [x] **6.3 Amazon:** AmazonMainActivity (31ms), AmazonLoginActivity (36ms), AmazonGamesActivity (27ms) all launch ✅
- [ ] **6.4** End-to-end: login → download → container picker → shortcut → launch via XServerDisplayActivity _(full flow testing pending)_
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
| Extension Java source (29 files) | `~/Ludashi-plus/extension/` |
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
| `main_menu_gog` | `0x7f0903a6` | sparse-switch entry + R$id field + menu item + public.xml pin |
| `main_menu_epic` | `0x7f0903a7` | sparse-switch entry + R$id field + menu item + public.xml pin |
| `main_menu_amazon` | `0x7f0903a8` | sparse-switch entry + R$id field + menu item + public.xml pin |

> **Note:** IDs `0x7f09027f–0x7f090281` (originally planned) are taken by MaterialComponents (`masked`, `material_clock_display`, `material_clock_face`). Final IDs are the 3 slots after `public.xml`'s last entry (`zero_corner_chip` = `0x7f0903a5`).

---

## Total File Changes

| Category | Count |
|---|---|
| Extension Java files | 29 (including LudashiLaunchBridge.java) |
| Smali patches | 2 |
| Resource patches | 3 |
| New DEX | 1 (classes17.dex, built by CI) |
| CI workflow | 1 |
| New manifest `<activity>` blocks | 9 |
| New menu items | 3 |
| **Total new/modified files** | **~38** |
