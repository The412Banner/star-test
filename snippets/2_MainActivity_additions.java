// FILE: com/winlator/cmod/MainActivity.java
// Two changes to MainActivity for the splash screen integration.
// These are source-code equivalents; production integration uses the
// patched smali in patches/smali_classes8/com/winlator/cmod/MainActivity.smali

package com.winlator.cmod;

// ============================================================================
// CHANGE 1: Remove permission requests from onCreate()
// ============================================================================
// BEFORE (original tail of onCreate, after setting up the main UI):
//
//   boolean needsPerms = requestAppPermissions();
//   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {   // API 30
//       if (!Environment.isExternalStorageManager()) {
//           showAllFilesAccessDialog();
//       }
//   }
//   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // API 33
//       if (ActivityCompat.checkSelfPermission(this, POST_NOTIFICATIONS) != PERMISSION_GRANTED) {
//           requestPermissions(new String[]{POST_NOTIFICATIONS}, 1);
//       }
//   }
//   installIfNeeded();
//
// AFTER (patched): call installIfNeeded() unconditionally, no permission checks
//
//   ImageFsInstaller.installIfNeeded(this);
//
// RATIONALE: installIfNeeded() calls getFilesDir() (internal storage) which
// needs NO permissions. The splash shows first, then doPermissionsFlow() is
// called via the "All Files Access Required" button AFTER install completes.
// ============================================================================


// ============================================================================
// CHANGE 2: New method doPermissionsFlow() — called by splash button
// ============================================================================
// Add this public method to MainActivity:

import android.os.Build;
import android.os.Environment;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity /* extends ... */ {

    /**
     * NEW METHOD — added in splash screen integration.
     *
     * Called by DownloadProgressDialog.showPermissionsButton() when the user
     * taps the "All Files Access Required" button after installation completes.
     *
     * Replicates the original onCreate() permission logic exactly.
     */
    public void doPermissionsFlow() {
        // Standard runtime permissions (WRITE_EXTERNAL_STORAGE etc.)
        requestAppPermissions();

        // API 30+ (Android 11+): Request MANAGE_EXTERNAL_STORAGE
        if (Build.VERSION.SDK_INT >= 30 /* Build.VERSION_CODES.R */) {
            if (!Environment.isExternalStorageManager()) {
                showAllFilesAccessDialog();
            }
        }

        // API 33+ (Android 13+): Request POST_NOTIFICATIONS
        if (Build.VERSION.SDK_INT >= 33 /* Build.VERSION_CODES.TIRAMISU */) {
            if (ActivityCompat.checkSelfPermission(
                    this,
                    "android.permission.POST_NOTIFICATIONS"
            ) != 0 /* PackageManager.PERMISSION_GRANTED */) {
                requestPermissions(
                    new String[]{"android.permission.POST_NOTIFICATIONS"},
                    1 /* request code */
                );
            }
        }
    }
}


// ============================================================================
// SMALI IMPLEMENTATION NOTES
// ============================================================================
//
// The smali equivalent uses these registers and patterns:
//
//   doPermissionsFlow registers: v0=SDK_INT, v1=const(api level), v2=String array
//
//   invoke-direct {p0}, ...requestAppPermissions()Z   (result discarded)
//   sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
//   const/16 v1, 0x1e   (30 = API R)
//   if-lt v0, v1, :cond_0
//   invoke-static {}, ...isExternalStorageManager()Z
//   move-result v0
//   if-nez v0, :cond_0
//   invoke-direct {p0}, ...showAllFilesAccessDialog()V
//   :cond_0
//   sget v0, ...SDK_INT:I
//   const/16 v1, 0x21   (33 = API TIRAMISU)
//   if-lt v0, v1, :cond_1
//   const-string v0, "android.permission.POST_NOTIFICATIONS"
//   invoke-static {p0, v0}, Landroidx/core/app/ActivityCompat;->checkSelfPermission(...)I
//   move-result v1
//   if-eqz v1, :cond_1
//   const/4 v1, 0x1
//   new-array v2, v1, [Ljava/lang/String;
//   const/4 v1, 0x0
//   aput-object v0, v2, v1
//   invoke-virtual {p0, v2, v1}, ...requestPermissions(...)V
//   :cond_1
//   return-void
//
// CRITICAL: The :goto_3 label MUST be preserved before return-void in
// the modified onCreate() — it is the jump target of an earlier goto.
// Removing it causes a "Cannot get the location of a label that hasn't
// been placed yet" error at smali assembly time.
