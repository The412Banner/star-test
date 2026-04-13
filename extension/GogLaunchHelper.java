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
}
