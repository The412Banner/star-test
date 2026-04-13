# Star Bionic (star-plus) Progress Log

---

### [stable] — v1.1.0 — Steam + cover art on shortcuts (2026-04-13)
**Commit:** `40c02ff` | **Tag:** v1.1.0 | **CI:** ✅ run 24341257114

#### What changed since v1.0.1
- Full Steam store integration (login, QR login, library sync, download, pause/resume/cancel, launch, uninstall, Add to Shortcuts)
- Cover art auto-saved into container XDG icon dir on "Add to Shortcuts" — shows in Winlator Shortcuts list immediately
- GOG, Epic, Amazon shortcuts also include cover art icon
- StarBionicLaunchBridge renamed from LudashiLaunchBridge

#### Root cause fix (cover art)
- ShortcutsAdapter reads `shortcut.icon` (from `Icon=` name → XDG icon dir lookup)
- Previous code wrote path to `Icon=` field (ignored for display) then to `customCoverArtPath` in [Extra Data] (only used by BigPicture)
- Fix: copy downloaded image to `{containerRoot}/.local/share/icons/hicolor/64x64/apps/{safeName}.png`, set `Icon={safeName}` in .desktop file

---

### [pre] — v1.0.9-pre — cover art XDG icon dir fix (2026-04-13)
**Commit:** `40c02ff` | CI: ✅ run 24340591565

### [pre] — v1.0.8-pre — customCoverArtPath fix (2026-04-13)
**Commit:** `083e11b` | CI: ✅ run 24338458496

### [pre] — v1.0.7-pre — CI auto-notes + pre-release pruning (2026-04-13)
**Commit:** `1606103` | CI: ✅ run 24334273695

### [pre] — v1.0.6-pre — GOG/Epic/Amazon cover art on shortcuts (2026-04-13)
**Commit:** `9bee16e`

### [pre] — v1.0.5-pre — Steam launch/add to shortcuts button (2026-04-13)
**Commit:** `2999c04`

---

### [stable] — v1.0.1 — splash + permissions fix (2026-04-12)
**Commit:** `741b0e8` | CI: ✅ run 24309784609

### [stable] — v1.0.0 — first build (2026-04-12)
GOG + Epic + Amazon store integration; all 9 Activities launch cleanly.
