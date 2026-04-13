package com.winlator.cmod.store;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

/**
 * Launch bridge for Star Bionic store integrations.
 *
 * Uses reflection to access ContainerManager so this class compiles against
 * android.jar alone — no Star Bionic stubs needed.
 *
 * Call addToLauncher() when a store game is ready to add. It shows a dialog
 * listing all Wine containers, then writes a .desktop shortcut file into the
 * selected container's desktop directory. The shortcut then appears in
 * Star Bionic's Shortcuts list where the user can launch and configure it.
 */
public final class StarBionicLaunchBridge {

    private StarBionicLaunchBridge() {}

    /**
     * Show a container picker dialog, then write a .desktop shortcut file
     * into the chosen container's Wine desktop directory. No cover art.
     */
    public static void addToLauncher(Activity activity, String gameName, String exePath) {
        new Thread(() -> showPicker(activity, gameName, exePath, null,
                new Handler(Looper.getMainLooper()))).start();
    }

    /**
     * Same as addToLauncher(activity, gameName, exePath) but with a pre-downloaded
     * local icon file path. Pass null to leave the icon blank.
     */
    public static void addToLauncher(Activity activity, String gameName, String exePath, String iconPath) {
        new Thread(() -> showPicker(activity, gameName, exePath, iconPath,
                new Handler(Looper.getMainLooper()))).start();
    }

    /**
     * Downloads coverUrl to a local cache file, then shows the container picker.
     * Use this when you have a remote art URL (GOG, Epic, Amazon, Steam CDN).
     * Falls back gracefully — shortcut is still created if the download fails.
     */
    public static void addToLauncherWithArt(Activity activity, String gameName,
                                             String exePath, String coverUrl) {
        new Thread(() -> {
            String iconPath = downloadCoverArt(activity, coverUrl, gameName);
            showPicker(activity, gameName, exePath, iconPath, new Handler(Looper.getMainLooper()));
        }).start();
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    private static void showPicker(Activity activity, String gameName, String exePath,
                                   String iconPath, Handler h) {
        try {
            Class<?> cmClass = Class.forName("com.winlator.cmod.container.ContainerManager");
            Object manager = cmClass.getConstructor(Context.class).newInstance(activity);
            Method getContainers = cmClass.getMethod("getContainers");
            List<?> containers = (List<?>) getContainers.invoke(manager);

            if (containers == null || containers.isEmpty()) {
                h.post(() -> Toast.makeText(activity,
                        "No Wine container found. Create one first.",
                        Toast.LENGTH_LONG).show());
                return;
            }

            // Build display names for the picker
            String[] names = new String[containers.size()];
            for (int i = 0; i < containers.size(); i++) {
                Object c = containers.get(i);
                try {
                    Method getName = c.getClass().getMethod("getName");
                    names[i] = (String) getName.invoke(c);
                } catch (Exception ignored) {}
                if (names[i] == null || names[i].isEmpty()) names[i] = "Container " + i;
            }

            h.post(() -> new AlertDialog.Builder(activity)
                    .setTitle("Select container for \"" + gameName + "\"")
                    .setItems(names, (dialog, which) ->
                            writeShortcut(activity, containers.get(which), gameName, exePath, iconPath, h))
                    .setNegativeButton("Cancel", null)
                    .show());

        } catch (Exception e) {
            h.post(() -> Toast.makeText(activity,
                    "Error loading containers: " + e.getMessage(),
                    Toast.LENGTH_LONG).show());
        }
    }

    /**
     * Downloads a cover art image from url and saves it to
     * getExternalFilesDir/store_covers/{sanitized gameName}.jpg.
     * Returns the local file path, or null on failure. Skips re-download if cached.
     */
    private static String downloadCoverArt(Context ctx, String url, String gameName) {
        if (url == null || url.isEmpty()) return null;
        try {
            File dir = new File(ctx.getExternalFilesDir(null), "store_covers");
            dir.mkdirs();
            String safeName = gameName.replaceAll("[^a-zA-Z0-9]", "_");
            File dest = new File(dir, safeName + ".jpg");
            if (dest.exists() && dest.length() > 0) return dest.getAbsolutePath();
            HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
            conn.setConnectTimeout(8_000);
            conn.setReadTimeout(15_000);
            conn.connect();
            if (conn.getResponseCode() == 200) {
                try (InputStream in = conn.getInputStream();
                     FileOutputStream out = new FileOutputStream(dest)) {
                    byte[] buf = new byte[8192]; int n;
                    while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
                }
                if (dest.length() > 0) return dest.getAbsolutePath();
            }
        } catch (Exception ignored) {}
        return null;
    }

    private static void writeShortcut(Activity activity, Object container,
                                      String gameName, String exePath, String iconPath, Handler h) {
        new Thread(() -> {
            try {
                Method getDesktopDir = container.getClass().getMethod("getDesktopDir");
                File desktopDir = (File) getDesktopDir.invoke(container);

                if (desktopDir == null) {
                    h.post(() -> Toast.makeText(activity,
                            "Container desktop directory not found.",
                            Toast.LENGTH_LONG).show());
                    return;
                }

                if (!desktopDir.exists() && !desktopDir.mkdirs()) {
                    h.post(() -> Toast.makeText(activity,
                            "Could not create desktop directory.",
                            Toast.LENGTH_LONG).show());
                    return;
                }

                // Sanitize game name for use as a filename
                String safeName = gameName.replaceAll("[\\\\/:*?\"<>|]", "_").trim();
                if (safeName.isEmpty()) safeName = "game";

                File shortcutFile = new File(desktopDir, safeName + ".desktop");

                // Z: = imagefs root. Convert Android path → Z:\gog_games\...\game.exe
                // Shortcut.java unescape() expects each \ encoded as \\\\ (4 chars) in file.
                String winPath = GogInstallPath.toWinePath(activity, exePath);
                String escapedWinPath = winPath.replace("\\", "\\\\\\\\");

                String coverArtLine = (iconPath != null && !iconPath.isEmpty())
                        ? "customCoverArtPath=" + iconPath + "\n"
                        : "";

                String content = "[Desktop Entry]\n"
                        + "Name=" + gameName + "\n"
                        + "Exec=wine " + escapedWinPath + "\n"
                        + "Icon=\n"
                        + "Type=Application\n"
                        + "StartupWMClass=explorer\n"
                        + "\n"
                        + "[Extra Data]\n"
                        + coverArtLine;

                try (FileWriter fw = new FileWriter(shortcutFile)) {
                    fw.write(content);
                }

                h.post(() -> Toast.makeText(activity,
                        "\"" + gameName + "\" added to Shortcuts.\n"
                                + "Open the side menu → Shortcuts to launch and configure it.",
                        Toast.LENGTH_LONG).show());

            } catch (Exception e) {
                h.post(() -> Toast.makeText(activity,
                        "Failed to add shortcut: " + e.getMessage(),
                        Toast.LENGTH_LONG).show());
            }
        }).start();
    }
}
