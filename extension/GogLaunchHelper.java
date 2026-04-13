package com.winlator.cmod.store;

import android.app.Activity;

/**
 * Launch bridge for GOG games in Star Bionic.
 * Delegates to StarBionicLaunchBridge.
 */
public final class GogLaunchHelper {

    private GogLaunchHelper() {}

    public static void addToLauncher(Activity activity, String gameName, String exePath) {
        StarBionicLaunchBridge.addToLauncher(activity, gameName, exePath);
    }

    /** Overload that downloads GOG cover art before writing the shortcut. */
    public static void addToLauncher(Activity activity, String gameName, String exePath, String imageUrl) {
        // GOG image URLs often start with "//" — normalise to https:
        String url = imageUrl != null && imageUrl.startsWith("//") ? "https:" + imageUrl : imageUrl;
        StarBionicLaunchBridge.addToLauncherWithArt(activity, gameName, exePath, url);
    }
}
