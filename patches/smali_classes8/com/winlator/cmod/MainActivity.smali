.class public Lcom/winlator/cmod/MainActivity;
.super Landroidx/appcompat/app/AppCompatActivity;
.source "MainActivity.java"

# interfaces
.implements Lcom/google/android/material/navigation/NavigationView$OnNavigationItemSelectedListener;


# static fields
.field public static final CONTAINER_PATTERN_COMPRESSION_LEVEL:B = 0x9t

.field public static final EDIT_INPUT_CONTROLS_REQUEST_CODE:B = 0x3t

.field public static final OPEN_DIRECTORY_REQUEST_CODE:B = 0x4t

.field public static final OPEN_FILE_REQUEST_CODE:B = 0x2t

.field public static final OPEN_IMAGE_REQUEST_CODE:B = 0x5t

.field public static PACKAGE_NAME:Ljava/lang/String; = null

.field public static final PERMISSION_WRITE_EXTERNAL_STORAGE_REQUEST_CODE:B = 0x1t


# instance fields
.field private containerManager:Lcom/winlator/cmod/container/ContainerManager;

.field private currentSaveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

.field private drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

.field private editInputControls:Z

.field private isDarkMode:Z

.field public final preloaderDialog:Lcom/winlator/cmod/core/PreloaderDialog;

.field private saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

.field private saveManager:Lcom/winlator/cmod/saves/SaveManager;

.field private saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

.field private selectedProfileId:I

.field private sharedPreferences:Landroid/content/SharedPreferences;


# direct methods
.method public static synthetic $r8$lambda$PQ_2cL5jQKUmZTkYlIV_MmAyFeo(Lcom/winlator/cmod/MainActivity;Landroid/content/DialogInterface;I)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/winlator/cmod/MainActivity;->lambda$showAllFilesAccessDialog$0(Landroid/content/DialogInterface;I)V

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    .line 55
    invoke-direct {p0}, Landroidx/appcompat/app/AppCompatActivity;-><init>()V

    .line 64
    new-instance v0, Lcom/winlator/cmod/core/PreloaderDialog;

    invoke-direct {v0, p0}, Lcom/winlator/cmod/core/PreloaderDialog;-><init>(Landroid/app/Activity;)V

    iput-object v0, p0, Lcom/winlator/cmod/MainActivity;->preloaderDialog:Lcom/winlator/cmod/core/PreloaderDialog;

    .line 65
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/winlator/cmod/MainActivity;->editInputControls:Z

    return-void
.end method

.method private synthetic lambda$showAllFilesAccessDialog$0(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .line 168
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 169
    .local v0, "intent":Landroid/content/Intent;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "package:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 170
    invoke-virtual {p0, v0}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V

    .line 171
    return-void
.end method

.method private requestAppPermissions()Z
    .locals 8

    .line 249
    const-string v0, "android.permission.WRITE_EXTERNAL_STORAGE"

    invoke-static {p0, v0}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v1

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-nez v1, :cond_0

    move v1, v3

    goto :goto_0

    :cond_0
    move v1, v2

    .line 250
    .local v1, "hasWritePermission":Z
    :goto_0
    const-string v4, "android.permission.READ_EXTERNAL_STORAGE"

    invoke-static {p0, v4}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v5

    if-nez v5, :cond_1

    move v5, v3

    goto :goto_1

    :cond_1
    move v5, v2

    .line 251
    .local v5, "hasReadPermission":Z
    :goto_1
    sget v6, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v7, 0x1e

    if-lt v6, v7, :cond_3

    invoke-static {}, Landroid/os/Environment;->isExternalStorageManager()Z

    move-result v6

    if-eqz v6, :cond_2

    goto :goto_2

    :cond_2
    move v6, v2

    goto :goto_3

    :cond_3
    :goto_2
    move v6, v3

    .line 253
    .local v6, "hasManageStoragePermission":Z
    :goto_3
    if-eqz v1, :cond_4

    if-eqz v5, :cond_4

    if-eqz v6, :cond_4

    .line 254
    return v2

    .line 257
    :cond_4
    if-eqz v1, :cond_5

    if-nez v5, :cond_6

    .line 258
    :cond_5
    const/4 v7, 0x2

    new-array v7, v7, [Ljava/lang/String;

    aput-object v0, v7, v2

    aput-object v4, v7, v3

    move-object v0, v7

    .line 259
    .local v0, "permissions":[Ljava/lang/String;
    invoke-static {p0, v0, v3}, Landroidx/core/app/ActivityCompat;->requestPermissions(Landroid/app/Activity;[Ljava/lang/String;I)V

    .line 262
    .end local v0    # "permissions":[Ljava/lang/String;
    :cond_6
    return v3
.end method

.method private setMenuItemTextColor(Landroid/view/MenuItem;I)V
    .locals 4
    .param p1, "menuItem"    # Landroid/view/MenuItem;
    .param p2, "color"    # I

    .line 452
    new-instance v0, Landroid/text/SpannableString;

    invoke-interface {p1}, Landroid/view/MenuItem;->getTitle()Ljava/lang/CharSequence;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/text/SpannableString;-><init>(Ljava/lang/CharSequence;)V

    .line 453
    .local v0, "spanString":Landroid/text/SpannableString;
    new-instance v1, Landroid/text/style/ForegroundColorSpan;

    invoke-direct {v1, p2}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    const/4 v2, 0x0

    invoke-virtual {v0}, Landroid/text/SpannableString;->length()I

    move-result v3

    invoke-virtual {v0, v1, v2, v3, v2}, Landroid/text/SpannableString;->setSpan(Ljava/lang/Object;III)V

    .line 454
    invoke-interface {p1, v0}, Landroid/view/MenuItem;->setTitle(Ljava/lang/CharSequence;)Landroid/view/MenuItem;

    .line 455
    return-void
.end method

.method private setNavigationViewItemTextColor(Lcom/google/android/material/navigation/NavigationView;I)V
    .locals 4
    .param p1, "navigationView"    # Lcom/google/android/material/navigation/NavigationView;
    .param p2, "color"    # I

    .line 437
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    invoke-virtual {p1}, Lcom/google/android/material/navigation/NavigationView;->getMenu()Landroid/view/Menu;

    move-result-object v1

    invoke-interface {v1}, Landroid/view/Menu;->size()I

    move-result v1

    if-ge v0, v1, :cond_1

    .line 438
    invoke-virtual {p1}, Lcom/google/android/material/navigation/NavigationView;->getMenu()Landroid/view/Menu;

    move-result-object v1

    invoke-interface {v1, v0}, Landroid/view/Menu;->getItem(I)Landroid/view/MenuItem;

    move-result-object v1

    .line 439
    .local v1, "menuItem":Landroid/view/MenuItem;
    invoke-direct {p0, v1, p2}, Lcom/winlator/cmod/MainActivity;->setMenuItemTextColor(Landroid/view/MenuItem;I)V

    .line 442
    invoke-interface {v1}, Landroid/view/MenuItem;->hasSubMenu()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 443
    const/4 v2, 0x0

    .local v2, "j":I
    :goto_1
    invoke-interface {v1}, Landroid/view/MenuItem;->getSubMenu()Landroid/view/SubMenu;

    move-result-object v3

    invoke-interface {v3}, Landroid/view/SubMenu;->size()I

    move-result v3

    if-ge v2, v3, :cond_0

    .line 444
    invoke-interface {v1}, Landroid/view/MenuItem;->getSubMenu()Landroid/view/SubMenu;

    move-result-object v3

    invoke-interface {v3, v2}, Landroid/view/SubMenu;->getItem(I)Landroid/view/MenuItem;

    move-result-object v3

    .line 445
    .local v3, "subMenuItem":Landroid/view/MenuItem;
    invoke-direct {p0, v3, p2}, Lcom/winlator/cmod/MainActivity;->setMenuItemTextColor(Landroid/view/MenuItem;I)V

    .line 443
    .end local v3    # "subMenuItem":Landroid/view/MenuItem;
    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 437
    .end local v1    # "menuItem":Landroid/view/MenuItem;
    .end local v2    # "j":I
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 449
    .end local v0    # "i":I
    :cond_1
    return-void
.end method

.method private show(Landroidx/fragment/app/Fragment;Z)V
    .locals 5
    .param p1, "fragment"    # Landroidx/fragment/app/Fragment;
    .param p2, "reverse"    # Z

    .line 361
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;

    move-result-object v0

    .line 362
    .local v0, "fragmentManager":Landroidx/fragment/app/FragmentManager;
    const v1, 0x7f090084

    if-eqz p2, :cond_0

    .line 363
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->beginTransaction()Landroidx/fragment/app/FragmentTransaction;

    move-result-object v2

    .line 364
    const v3, 0x7f010022

    const v4, 0x7f010029

    invoke-virtual {v2, v3, v4}, Landroidx/fragment/app/FragmentTransaction;->setCustomAnimations(II)Landroidx/fragment/app/FragmentTransaction;

    move-result-object v2

    .line 365
    invoke-virtual {v2, v1, p1}, Landroidx/fragment/app/FragmentTransaction;->replace(ILandroidx/fragment/app/Fragment;)Landroidx/fragment/app/FragmentTransaction;

    move-result-object v1

    .line 366
    invoke-virtual {v1}, Landroidx/fragment/app/FragmentTransaction;->commit()I

    goto :goto_0

    .line 368
    :cond_0
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->beginTransaction()Landroidx/fragment/app/FragmentTransaction;

    move-result-object v2

    .line 369
    const v3, 0x7f010025

    const v4, 0x7f010026

    invoke-virtual {v2, v3, v4}, Landroidx/fragment/app/FragmentTransaction;->setCustomAnimations(II)Landroidx/fragment/app/FragmentTransaction;

    move-result-object v2

    .line 370
    invoke-virtual {v2, v1, p1}, Landroidx/fragment/app/FragmentTransaction;->replace(ILandroidx/fragment/app/Fragment;)Landroidx/fragment/app/FragmentTransaction;

    move-result-object v1

    .line 371
    invoke-virtual {v1}, Landroidx/fragment/app/FragmentTransaction;->commit()I

    .line 374
    :goto_0
    iget-object v1, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    const v2, 0x800003

    invoke-virtual {v1, v2}, Landroidx/drawerlayout/widget/DrawerLayout;->closeDrawer(I)V

    .line 375
    return-void
.end method

.method private showAboutDialog()V
    .locals 11

    .line 378
    const-string v0, "---"

    const-string v1, "<br />"

    new-instance v2, Lcom/winlator/cmod/contentdialog/ContentDialog;

    const v3, 0x7f0c001c

    invoke-direct {v2, p0, v3}, Lcom/winlator/cmod/contentdialog/ContentDialog;-><init>(Landroid/content/Context;I)V

    .line 379
    .local v2, "dialog":Lcom/winlator/cmod/contentdialog/ContentDialog;
    const v3, 0x7f090093

    invoke-virtual {v2, v3}, Lcom/winlator/cmod/contentdialog/ContentDialog;->findViewById(I)Landroid/view/View;

    move-result-object v3

    const/16 v4, 0x8

    invoke-virtual {v3, v4}, Landroid/view/View;->setVisibility(I)V

    .line 381
    iget-boolean v3, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    if-eqz v3, :cond_0

    .line 382
    invoke-virtual {v2}, Lcom/winlator/cmod/contentdialog/ContentDialog;->getWindow()Landroid/view/Window;

    move-result-object v3

    const v5, 0x7f0800f3

    invoke-virtual {v3, v5}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    goto :goto_0

    .line 384
    :cond_0
    invoke-virtual {v2}, Lcom/winlator/cmod/contentdialog/ContentDialog;->getWindow()Landroid/view/Window;

    move-result-object v3

    const v5, 0x7f0800f2

    invoke-virtual {v3, v5}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    .line 388
    :goto_0
    :try_start_0
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v3

    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getPackageName()Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x0

    invoke-virtual {v3, v5, v6}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v3

    .line 390
    .local v3, "pInfo":Landroid/content/pm/PackageInfo;
    const v5, 0x7f090177

    invoke-virtual {v2, v5}, Lcom/winlator/cmod/contentdialog/ContentDialog;->findViewById(I)Landroid/view/View;

    move-result-object v5

    check-cast v5, Landroid/widget/TextView;

    .line 391
    .local v5, "tvWebpage":Landroid/widget/TextView;
    const-string v7, "<a href=\"https://sites.google.com/view/staremu\">star-emu</a>"

    invoke-static {v7, v6}, Landroid/text/Html;->fromHtml(Ljava/lang/String;I)Landroid/text/Spanned;

    move-result-object v7

    invoke-virtual {v5, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 392
    invoke-static {}, Landroid/text/method/LinkMovementMethod;->getInstance()Landroid/text/method/MovementMethod;

    move-result-object v7

    invoke-virtual {v5, v7}, Landroid/widget/TextView;->setMovementMethod(Landroid/text/method/MovementMethod;)V

    .line 394
    const v7, 0x7f09011f

    invoke-virtual {v2, v7}, Lcom/winlator/cmod/contentdialog/ContentDialog;->findViewById(I)Landroid/view/View;

    move-result-object v7

    check-cast v7, Landroid/widget/TextView;

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const v9, 0x7f10027b

    invoke-virtual {p0, v9}, Lcom/winlator/cmod/MainActivity;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, " "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    iget-object v9, v3, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 396
    const/16 v7, 0x15

    new-array v7, v7, [Ljava/lang/CharSequence;

    const-string v8, "Made with \u2764\ufe0f by the star Team."

    aput-object v8, v7, v6

    const-string v8, "Big shoutouts to <a href=\"https://github.com/coffincolors/winlator\">coffincolors</a>, <a href=\"https://github.com/Pipetto-crypto/winlator\">Pipetto-crypto</a> for creating Winlator bionic and to <a href=\"https://github.com/StevenMXZ\">StevenMXZ</a> and <a href=\"https://github.com/Xnick417x\">Xnick417x</a> for his useful stuffs."

    const/4 v9, 0x1

    aput-object v8, v7, v9

    const-string v8, "Big Picture Mode Music by"

    const/4 v10, 0x2

    aput-object v8, v7, v10

    const-string v8, "Dale Melvin Blevens III (Fumer)"

    const/4 v10, 0x3

    aput-object v8, v7, v10

    const/4 v8, 0x4

    aput-object v0, v7, v8

    const-string v8, "Official social media of star emulator (please follow it for more news about Star Emulator development!):"

    const/4 v10, 0x5

    aput-object v8, v7, v10

    const-string v8, "Discord (<a href=\"https://discord.gg/Q74CNHJnq2\">dsc.gg/staremul</a>)"

    const/4 v10, 0x6

    aput-object v8, v7, v10

    const-string v8, "Telegram (<a href=\"https://t.me/staremul\">t.me/staremul</a>)"

    const/4 v10, 0x7

    aput-object v8, v7, v10

    const-string v8, "YouTube (for more testing gameplay in star emulator) (<a href=\"https://youtube.com/@starwindowsemulator?si=Scup37Opu65PFBai\">youtube.com/@StarWindowsEmulator</a>)"

    aput-object v8, v7, v4

    const/16 v4, 0x9

    aput-object v0, v7, v4

    const-string v0, "Termux Package(<a href=\"https://github.com/termux/termux-packages\">github.com/termux/termux-package</a>)"

    const/16 v4, 0xa

    aput-object v0, v7, v4

    const-string v0, "Wine (<a href=\"https://www.winehq.org\">winehq.org</a>)"

    const/16 v4, 0xb

    aput-object v0, v7, v4

    const-string v0, "Box64 (<a href=\"https://github.com/ptitSeb/box64\">github.com/ptitSeb/box64</a>)"

    const/16 v4, 0xc

    aput-object v0, v7, v4

    const-string v0, "Mesa (Turnip/Zink/Wrapper) (<a href=\"https://github.com/xMeM/mesa/tree/wrapper\">github.com/xMeM/mesa</a>)"

    const/16 v4, 0xd

    aput-object v0, v7, v4

    const-string v0, "DXVK (<a href=\"https://github.com/doitsujin/dxvk\">github.com/doitsujin/dxvk</a>)"

    const/16 v4, 0xe

    aput-object v0, v7, v4

    const-string v0, "VKD3D (<a href=\"https://gitlab.winehq.org/wine/vkd3d\">gitlab.winehq.org/wine/vkd3d</a>)"

    const/16 v4, 0xf

    aput-object v0, v7, v4

    const-string v0, "D8VK (<a href=\"https://github.com/AlpyneDreams/d8vk\">github.com/AlpyneDreams/d8vk</a>)"

    const/16 v4, 0x10

    aput-object v0, v7, v4

    const-string v0, "CNC DDraw (<a href=\"https://github.com/FunkyFr3sh/cnc-ddraw\">github.com/FunkyFr3sh/cnc-ddraw</a>)"

    const/16 v4, 0x11

    aput-object v0, v7, v4

    const-string v0, "dxwrapper (<a href=\"https://github.com/elishacloud/dxwrapper\">github.com/elishacloud/dxwrapper</a>)"

    const/16 v4, 0x12

    aput-object v0, v7, v4

    const-string v0, "FEX-Emu (<a href=\"https://github.com/FEX-Emu/FEX\">github.com/FEX-Emu/FEX</a>)"

    const/16 v4, 0x13

    aput-object v0, v7, v4

    const-string v0, "libadrenotools (<a href=\"https://github.com/bylaws/libadrenotools\">github.com/bylaws/libadrenotools</a>)"

    const/16 v4, 0x14

    aput-object v0, v7, v4

    invoke-static {v1, v7}, Ljava/lang/String;->join(Ljava/lang/CharSequence;[Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v0

    .line 420
    .local v0, "creditsAndThirdPartyAppsHTML":Ljava/lang/String;
    const v4, 0x7f09012f

    invoke-virtual {v2, v4}, Lcom/winlator/cmod/contentdialog/ContentDialog;->findViewById(I)Landroid/view/View;

    move-result-object v4

    check-cast v4, Landroid/widget/TextView;

    .line 421
    .local v4, "tvCreditsAndThirdPartyApps":Landroid/widget/TextView;
    invoke-static {v0, v6}, Landroid/text/Html;->fromHtml(Ljava/lang/String;I)Landroid/text/Spanned;

    move-result-object v7

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 422
    invoke-static {}, Landroid/text/method/LinkMovementMethod;->getInstance()Landroid/text/method/MovementMethod;

    move-result-object v7

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setMovementMethod(Landroid/text/method/MovementMethod;)V

    .line 424
    new-array v7, v9, [Ljava/lang/CharSequence;

    const-string v8, "longjunyu2 <a href=\"https://github.com/longjunyu2/winlator/tree/use-glibc-instead-of-proot\">(GLIBC Fork)</a>"

    aput-object v8, v7, v6

    invoke-static {v1, v7}, Ljava/lang/String;->join(Ljava/lang/CharSequence;[Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v1

    .line 426
    .local v1, "glibcExpVersionForkHTML":Ljava/lang/String;
    const v7, 0x7f090149

    invoke-virtual {v2, v7}, Lcom/winlator/cmod/contentdialog/ContentDialog;->findViewById(I)Landroid/view/View;

    move-result-object v7

    check-cast v7, Landroid/widget/TextView;

    .line 427
    .local v7, "tvGlibcExpVersionFork":Landroid/widget/TextView;
    invoke-static {v1, v6}, Landroid/text/Html;->fromHtml(Ljava/lang/String;I)Landroid/text/Spanned;

    move-result-object v6

    invoke-virtual {v7, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 428
    invoke-static {}, Landroid/text/method/LinkMovementMethod;->getInstance()Landroid/text/method/MovementMethod;

    move-result-object v6

    invoke-virtual {v7, v6}, Landroid/widget/TextView;->setMovementMethod(Landroid/text/method/MovementMethod;)V
    :try_end_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_0} :catch_0

    .line 431
    .end local v0    # "creditsAndThirdPartyAppsHTML":Ljava/lang/String;
    .end local v1    # "glibcExpVersionForkHTML":Ljava/lang/String;
    .end local v3    # "pInfo":Landroid/content/pm/PackageInfo;
    .end local v4    # "tvCreditsAndThirdPartyApps":Landroid/widget/TextView;
    .end local v5    # "tvWebpage":Landroid/widget/TextView;
    .end local v7    # "tvGlibcExpVersionFork":Landroid/widget/TextView;
    goto :goto_1

    .line 429
    :catch_0
    move-exception v0

    .line 430
    .local v0, "e":Landroid/content/pm/PackageManager$NameNotFoundException;
    invoke-virtual {v0}, Landroid/content/pm/PackageManager$NameNotFoundException;->printStackTrace()V

    .line 433
    .end local v0    # "e":Landroid/content/pm/PackageManager$NameNotFoundException;
    :goto_1
    invoke-virtual {v2}, Lcom/winlator/cmod/contentdialog/ContentDialog;->show()V

    .line 434
    return-void
.end method

.method private showAllFilesAccessDialog()V
    .locals 3

    .line 164
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 165
    const-string v1, "All Files Access Required"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 166
    const-string v1, "In order to grant access to additional storage devices such as USB storage device, the All Files Access permission must be granted. Press Okay to grant All Files Access in your Android Settings."

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lcom/winlator/cmod/MainActivity$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0}, Lcom/winlator/cmod/MainActivity$$ExternalSyntheticLambda0;-><init>(Lcom/winlator/cmod/MainActivity;)V

    .line 167
    const-string v2, "Okay"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 172
    const-string v1, "Cancel"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 173
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 174
    return-void
.end method

.method private showSavesFragment()V
    .locals 3

    .line 205
    new-instance v0, Lcom/winlator/cmod/SavesFragment;

    invoke-direct {v0}, Lcom/winlator/cmod/SavesFragment;-><init>()V

    .line 206
    .local v0, "fragment":Lcom/winlator/cmod/SavesFragment;
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;

    move-result-object v1

    invoke-virtual {v1}, Landroidx/fragment/app/FragmentManager;->beginTransaction()Landroidx/fragment/app/FragmentTransaction;

    move-result-object v1

    .line 207
    const v2, 0x7f090084

    invoke-virtual {v1, v2, v0}, Landroidx/fragment/app/FragmentTransaction;->replace(ILandroidx/fragment/app/Fragment;)Landroidx/fragment/app/FragmentTransaction;

    move-result-object v1

    .line 208
    invoke-virtual {v1}, Landroidx/fragment/app/FragmentTransaction;->commit()I

    .line 209
    return-void
.end method


# virtual methods
.method public onActivityResult(IILandroid/content/Intent;)V
    .locals 3
    .param p1, "requestCode"    # I
    .param p2, "resultCode"    # I
    .param p3, "data"    # Landroid/content/Intent;

    .line 189
    invoke-super {p0, p1, p2, p3}, Landroidx/appcompat/app/AppCompatActivity;->onActivityResult(IILandroid/content/Intent;)V

    .line 191
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "onActivityResult called with requestCode: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " and resultCode: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "WinActivity"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 193
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 194
    const-string v0, "Forwarding result to SaveSettingsDialog"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 195
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    invoke-virtual {v0, p1, p2, p3}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;->onActivityResult(IILandroid/content/Intent;)V

    goto :goto_0

    .line 196
    :cond_0
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 197
    const-string v0, "Forwarding result to SaveEditDialog"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 198
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v0, p1, p2, p3}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->onActivityResult(IILandroid/content/Intent;)V

    goto :goto_0

    .line 200
    :cond_1
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "No dialog found for request code: "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 202
    :goto_0
    return-void
.end method

.method public onBackPressed()V
    .locals 5

    .line 234
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;

    move-result-object v0

    .line 235
    .local v0, "fragmentManager":Landroidx/fragment/app/FragmentManager;
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->getFragments()Ljava/util/List;

    move-result-object v1

    .line 236
    .local v1, "fragments":Ljava/util/List;, "Ljava/util/List<Landroidx/fragment/app/Fragment;>;"
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroidx/fragment/app/Fragment;

    .line 237
    .local v3, "fragment":Landroidx/fragment/app/Fragment;
    instance-of v4, v3, Lcom/winlator/cmod/ContainersFragment;

    if-eqz v4, :cond_0

    invoke-virtual {v3}, Landroidx/fragment/app/Fragment;->isVisible()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 238
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->finish()V

    .line 239
    return-void

    .line 241
    .end local v3    # "fragment":Landroidx/fragment/app/Fragment;
    :cond_0
    goto :goto_0

    .line 242
    :cond_1
    iget-boolean v2, p0, Lcom/winlator/cmod/MainActivity;->editInputControls:Z

    if-nez v2, :cond_2

    .line 243
    new-instance v2, Lcom/winlator/cmod/ContainersFragment;

    invoke-direct {v2}, Lcom/winlator/cmod/ContainersFragment;-><init>()V

    const/4 v3, 0x1

    invoke-direct {p0, v2, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    goto :goto_1

    .line 245
    :cond_2
    invoke-super {p0}, Landroidx/appcompat/app/AppCompatActivity;->onBackPressed()V

    .line 246
    :goto_1
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 13
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 78
    const/4 v0, 0x1
    invoke-static {v0}, Landroidx/appcompat/app/AppCompatDelegate;->setCompatVectorFromResourcesEnabled(Z)V

    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onCreate(Landroid/os/Bundle;)V

    .line 81
    invoke-static {p0}, Landroidx/preference/PreferenceManager;->getDefaultSharedPreferences(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    .line 84
    .local v0, "sharedPreferences":Landroid/content/SharedPreferences;
    const-string v1, "enable_big_picture_mode"

    const/4 v2, 0x0

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result v1

    .line 86
    .local v1, "isBigPictureModeEnabled":Z
    if-eqz v1, :cond_0

    .line 88
    new-instance v3, Landroid/content/Intent;

    const-class v4, Lcom/winlator/cmod/BigPictureActivity;

    invoke-direct {v3, p0, v4}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 89
    .local v3, "intent":Landroid/content/Intent;
    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->startActivity(Landroid/content/Intent;)V

    .line 93
    .end local v3    # "intent":Landroid/content/Intent;
    :cond_0
    invoke-static {p0}, Landroidx/preference/PreferenceManager;->getDefaultSharedPreferences(Landroid/content/Context;)Landroid/content/SharedPreferences;

    move-result-object v0

    .line 94
    const-string v3, "dark_mode"

    invoke-interface {v0, v3, v2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z

    move-result v3

    iput-boolean v3, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    .line 97
    iget-boolean v3, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    if-eqz v3, :cond_1

    .line 98
    const v3, 0x7f110009

    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->setTheme(I)V

    goto :goto_0

    .line 100
    :cond_1
    const v3, 0x7f110008

    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->setTheme(I)V

    .line 104
    :goto_0
    const v3, 0x7f0c0060

    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->setContentView(I)V

    .line 106
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getApplicationContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v3

    sput-object v3, Lcom/winlator/cmod/MainActivity;->PACKAGE_NAME:Ljava/lang/String;

    .line 108
    const v3, 0x7f090075

    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroidx/drawerlayout/widget/DrawerLayout;

    iput-object v3, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    .line 109
    const v3, 0x7f0900b6

    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Lcom/google/android/material/navigation/NavigationView;

    .line 110
    .local v3, "navigationView":Lcom/google/android/material/navigation/NavigationView;
    invoke-virtual {v3, p0}, Lcom/google/android/material/navigation/NavigationView;->setNavigationItemSelectedListener(Lcom/google/android/material/navigation/NavigationView$OnNavigationItemSelectedListener;)V

    .line 112
    const v4, 0x7f09017e

    invoke-virtual {p0, v4}, Lcom/winlator/cmod/MainActivity;->findViewById(I)Landroid/view/View;

    move-result-object v4

    check-cast v4, Landroidx/appcompat/widget/Toolbar;

    invoke-virtual {p0, v4}, Lcom/winlator/cmod/MainActivity;->setSupportActionBar(Landroidx/appcompat/widget/Toolbar;)V

    .line 113
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportActionBar()Landroidx/appcompat/app/ActionBar;

    move-result-object v4

    .line 114
    .local v4, "actionBar":Landroidx/appcompat/app/ActionBar;
    const v5, 0x7f080118

    const/4 v6, 0x1

    if-eqz v4, :cond_2

    .line 115
    invoke-virtual {v4, v6}, Landroidx/appcompat/app/ActionBar;->setDisplayHomeAsUpEnabled(Z)V

    .line 116
    invoke-virtual {v4, v5}, Landroidx/appcompat/app/ActionBar;->setHomeAsUpIndicator(I)V

    .line 120
    :cond_2
    iget-boolean v7, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    if-eqz v7, :cond_3

    const/4 v7, -0x1

    goto :goto_1

    :cond_3
    const/high16 v7, -0x1000000

    .line 121
    .local v7, "textColor":I
    :goto_1
    invoke-direct {p0, v3, v7}, Lcom/winlator/cmod/MainActivity;->setNavigationViewItemTextColor(Lcom/google/android/material/navigation/NavigationView;I)V

    .line 124
    new-instance v8, Ljava/io/File;

    sget-object v9, Lcom/winlator/cmod/SettingsFragment;->DEFAULT_WINLATOR_PATH:Ljava/lang/String;

    invoke-direct {v8, v9}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 125
    .local v8, "winlatorDir":Ljava/io/File;
    invoke-virtual {v8}, Ljava/io/File;->exists()Z

    move-result v9

    if-nez v9, :cond_4

    .line 126
    invoke-virtual {v8}, Ljava/io/File;->mkdirs()Z

    .line 129
    :cond_4
    new-instance v9, Lcom/winlator/cmod/saves/SaveManager;

    invoke-direct {v9, p0}, Lcom/winlator/cmod/saves/SaveManager;-><init>(Landroid/content/Context;)V

    iput-object v9, p0, Lcom/winlator/cmod/MainActivity;->saveManager:Lcom/winlator/cmod/saves/SaveManager;

    .line 130
    new-instance v9, Lcom/winlator/cmod/container/ContainerManager;

    invoke-direct {v9, p0}, Lcom/winlator/cmod/container/ContainerManager;-><init>(Landroid/content/Context;)V

    iput-object v9, p0, Lcom/winlator/cmod/MainActivity;->containerManager:Lcom/winlator/cmod/container/ContainerManager;

    .line 132
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getIntent()Landroid/content/Intent;

    move-result-object v9

    .line 133
    .local v9, "intent":Landroid/content/Intent;
    const-string v10, "edit_input_controls"

    invoke-virtual {v9, v10, v2}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v10

    iput-boolean v10, p0, Lcom/winlator/cmod/MainActivity;->editInputControls:Z

    .line 134
    iget-boolean v10, p0, Lcom/winlator/cmod/MainActivity;->editInputControls:Z

    if-eqz v10, :cond_5

    .line 135
    const-string v5, "selected_profile_id"

    invoke-virtual {v9, v5, v2}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v2

    iput v2, p0, Lcom/winlator/cmod/MainActivity;->selectedProfileId:I

    .line 136
    const v2, 0x7f080116

    invoke-virtual {v4, v2}, Landroidx/appcompat/app/ActionBar;->setHomeAsUpIndicator(I)V

    .line 137
    invoke-virtual {v3}, Lcom/google/android/material/navigation/NavigationView;->getMenu()Landroid/view/Menu;

    move-result-object v2

    const v5, 0x7f090271

    invoke-interface {v2, v5}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v2

    invoke-virtual {p0, v2}, Lcom/winlator/cmod/MainActivity;->onNavigationItemSelected(Landroid/view/MenuItem;)Z

    .line 138
    invoke-virtual {v3, v5}, Lcom/google/android/material/navigation/NavigationView;->setCheckedItem(I)V

    goto :goto_3

    .line 140
    :cond_5
    const-string v10, "selected_menu_item_id"

    invoke-virtual {v9, v10, v2}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v10

    .line 141
    .local v10, "selectedMenuItemId":I
    if-lez v10, :cond_6

    move v11, v10

    goto :goto_2

    :cond_6
    const v11, 0x7f09026c

    .line 143
    .local v11, "menuItemId":I
    :goto_2
    invoke-virtual {v4, v5}, Landroidx/appcompat/app/ActionBar;->setHomeAsUpIndicator(I)V

    .line 144
    invoke-virtual {v3}, Lcom/google/android/material/navigation/NavigationView;->getMenu()Landroid/view/Menu;

    move-result-object v5

    invoke-interface {v5, v11}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v5

    invoke-virtual {p0, v5}, Lcom/winlator/cmod/MainActivity;->onNavigationItemSelected(Landroid/view/MenuItem;)Z

    .line 145
    invoke-virtual {v3, v11}, Lcom/google/android/material/navigation/NavigationView;->setCheckedItem(I)V

    .line 147
    invoke-static {p0}, Lcom/winlator/cmod/xenvironment/ImageFsInstaller;->installIfNeeded(Lcom/winlator/cmod/MainActivity;)V

    .end local v10    # "selectedMenuItemId":I
    .end local v11    # "menuItemId":I
    return-void
.end method

.method public doPermissionsFlow()V
    .locals 3

    invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->requestAppPermissions()Z

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    invoke-static {}, Landroid/os/Environment;->isExternalStorageManager()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->showAllFilesAccessDialog()V

    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

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

.method public onNavigationItemSelected(Landroid/view/MenuItem;)Z
    .locals 5
    .param p1, "item"    # Landroid/view/MenuItem;

    .line 316
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;

    move-result-object v0

    .line 317
    .local v0, "fragmentManager":Landroidx/fragment/app/FragmentManager;
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->getBackStackEntryCount()I

    move-result v1

    const/4 v2, 0x1

    if-lez v1, :cond_0

    .line 318
    const/4 v1, 0x0

    invoke-virtual {v0, v1, v2}, Landroidx/fragment/app/FragmentManager;->popBackStack(Ljava/lang/String;I)V

    .line 321
    :cond_0
    invoke-interface {p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v1

    const/4 v3, 0x0

    sparse-switch v1, :sswitch_data_0

    goto :goto_0

    .line 323
    :sswitch_0
    new-instance v1, Lcom/winlator/cmod/ShortcutsFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/ShortcutsFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 324
    goto :goto_0

    .line 341
    :sswitch_1
    new-instance v1, Lcom/winlator/cmod/SettingsFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/SettingsFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 342
    goto :goto_0

    .line 338
    :sswitch_2
    new-instance v1, Lcom/winlator/cmod/SavesFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/SavesFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 339
    goto :goto_0

    .line 329
    :sswitch_3
    new-instance v1, Lcom/winlator/cmod/InputControlsFragment;

    iget v4, p0, Lcom/winlator/cmod/MainActivity;->selectedProfileId:I

    invoke-direct {v1, v4}, Lcom/winlator/cmod/InputControlsFragment;-><init>(I)V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 330
    goto :goto_0

    .line 332
    :sswitch_4
    new-instance v1, Lcom/winlator/cmod/ContentsFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/ContentsFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 333
    goto :goto_0

    .line 326
    :sswitch_5
    new-instance v1, Lcom/winlator/cmod/ContainersFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/ContainersFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 327
    goto :goto_0

    .line 335
    :sswitch_6
    new-instance v1, Lcom/winlator/cmod/AdrenotoolsFragment;

    invoke-direct {v1}, Lcom/winlator/cmod/AdrenotoolsFragment;-><init>()V

    invoke-direct {p0, v1, v3}, Lcom/winlator/cmod/MainActivity;->show(Landroidx/fragment/app/Fragment;Z)V

    .line 336
    goto :goto_0

    .line 344
    :sswitch_7
    invoke-direct {p0}, Lcom/winlator/cmod/MainActivity;->showAboutDialog()V

    .line 347
    :goto_0
    return v2

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

    :sswitch_data_0
    .sparse-switch
        0x7f090269 -> :sswitch_7
        0x7f09026b -> :sswitch_6
        0x7f09026c -> :sswitch_5
        0x7f09026d -> :sswitch_4
        0x7f090271 -> :sswitch_3
        0x7f090279 -> :sswitch_2
        0x7f09027b -> :sswitch_1
        0x7f09027c -> :sswitch_0
        0x7f0903a6 -> :sswitch_8
        0x7f0903a7 -> :sswitch_9
        0x7f0903a8 -> :sswitch_a
    .end sparse-switch
.end method

.method public onOptionsItemSelected(Landroid/view/MenuItem;)Z
    .locals 7
    .param p1, "menuItem"    # Landroid/view/MenuItem;

    .line 267
    invoke-interface {p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v0

    const v1, 0x102002c

    const/4 v2, 0x1

    if-ne v0, v1, :cond_1

    .line 269
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    const v1, 0x800003

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->isDrawerOpen(I)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 270
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->closeDrawer(I)V

    goto :goto_0

    .line 272
    :cond_0
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->openDrawer(I)V

    .line 274
    :goto_0
    return v2

    .line 275
    :cond_1
    invoke-interface {p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v0

    const v1, 0x7f090306

    if-ne v0, v1, :cond_6

    .line 277
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    .line 278
    .local v0, "intent":Landroid/content/Intent;
    const-string v1, "edit_save_id"

    const/4 v3, -0x1

    invoke-virtual {v0, v1, v3}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v1

    .line 279
    .local v1, "editSaveId":I
    if-ltz v1, :cond_2

    iget-object v3, p0, Lcom/winlator/cmod/MainActivity;->saveManager:Lcom/winlator/cmod/saves/SaveManager;

    invoke-virtual {v3, v1}, Lcom/winlator/cmod/saves/SaveManager;->getSaveById(I)Lcom/winlator/cmod/saves/Save;

    move-result-object v3

    goto :goto_1

    :cond_2
    const/4 v3, 0x0

    .line 282
    .local v3, "saveToEdit":Lcom/winlator/cmod/saves/Save;
    :goto_1
    if-eqz v3, :cond_4

    .line 284
    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    if-eqz v4, :cond_3

    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v4}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->isShowing()Z

    move-result v4

    if-eqz v4, :cond_3

    .line 285
    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v4}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->dismiss()V

    .line 287
    :cond_3
    invoke-virtual {p0, v3}, Lcom/winlator/cmod/MainActivity;->showSaveEditDialog(Lcom/winlator/cmod/saves/Save;)V

    goto :goto_3

    .line 289
    :cond_4
    new-instance v4, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    iget-object v5, p0, Lcom/winlator/cmod/MainActivity;->saveManager:Lcom/winlator/cmod/saves/SaveManager;

    iget-object v6, p0, Lcom/winlator/cmod/MainActivity;->containerManager:Lcom/winlator/cmod/container/ContainerManager;

    invoke-direct {v4, p0, v5, v6}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;-><init>(Landroid/app/Activity;Lcom/winlator/cmod/saves/SaveManager;Lcom/winlator/cmod/container/ContainerManager;)V

    iput-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    .line 292
    iget-boolean v4, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    if-eqz v4, :cond_5

    .line 293
    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    invoke-virtual {v4}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;->getWindow()Landroid/view/Window;

    move-result-object v4

    const v5, 0x7f0800f3

    invoke-virtual {v4, v5}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    goto :goto_2

    .line 295
    :cond_5
    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    invoke-virtual {v4}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;->getWindow()Landroid/view/Window;

    move-result-object v4

    const v5, 0x7f0800f2

    invoke-virtual {v4, v5}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    .line 298
    :goto_2
    iget-object v4, p0, Lcom/winlator/cmod/MainActivity;->saveSettingsDialog:Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;

    invoke-virtual {v4}, Lcom/winlator/cmod/contentdialog/SaveSettingsDialog;->show()V

    .line 300
    :goto_3
    return v2

    .line 302
    .end local v0    # "intent":Landroid/content/Intent;
    .end local v1    # "editSaveId":I
    .end local v3    # "saveToEdit":Lcom/winlator/cmod/saves/Save;
    :cond_6
    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onOptionsItemSelected(Landroid/view/MenuItem;)Z

    move-result v0

    return v0
.end method

.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 1
    .param p1, "requestCode"    # I
    .param p2, "permissions"    # [Ljava/lang/String;
    .param p3, "grantResults"    # [I

    .line 178
    invoke-super {p0, p1, p2, p3}, Landroidx/appcompat/app/AppCompatActivity;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V

    .line 179
    const/4 v0, 0x1

    if-ne p1, v0, :cond_1

    .line 180
    array-length v0, p3

    if-lez v0, :cond_0

    const/4 v0, 0x0

    aget v0, p3, v0

    if-nez v0, :cond_0

    .line 181
    invoke-static {p0}, Lcom/winlator/cmod/xenvironment/ImageFsInstaller;->installIfNeeded(Lcom/winlator/cmod/MainActivity;)V

    goto :goto_0

    .line 183
    :cond_0
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->finish()V

    .line 185
    :cond_1
    :goto_0
    return-void
.end method

.method public onSaveAdded()V
    .locals 2

    .line 226
    invoke-virtual {p0}, Lcom/winlator/cmod/MainActivity;->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;

    move-result-object v0

    const v1, 0x7f090084

    invoke-virtual {v0, v1}, Landroidx/fragment/app/FragmentManager;->findFragmentById(I)Landroidx/fragment/app/Fragment;

    move-result-object v0

    .line 227
    .local v0, "currentFragment":Landroidx/fragment/app/Fragment;
    instance-of v1, v0, Lcom/winlator/cmod/SavesFragment;

    if-eqz v1, :cond_0

    .line 228
    move-object v1, v0

    check-cast v1, Lcom/winlator/cmod/SavesFragment;

    invoke-virtual {v1}, Lcom/winlator/cmod/SavesFragment;->refreshSavesList()V

    .line 230
    :cond_0
    return-void
.end method

.method public showSaveEditDialog(Lcom/winlator/cmod/saves/Save;)V
    .locals 3
    .param p1, "saveToEdit"    # Lcom/winlator/cmod/saves/Save;

    .line 213
    new-instance v0, Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    iget-object v1, p0, Lcom/winlator/cmod/MainActivity;->saveManager:Lcom/winlator/cmod/saves/SaveManager;

    iget-object v2, p0, Lcom/winlator/cmod/MainActivity;->containerManager:Lcom/winlator/cmod/container/ContainerManager;

    invoke-direct {v0, p0, v1, v2, p1}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;-><init>(Landroid/app/Activity;Lcom/winlator/cmod/saves/SaveManager;Lcom/winlator/cmod/container/ContainerManager;Lcom/winlator/cmod/saves/Save;)V

    iput-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    .line 216
    iget-boolean v0, p0, Lcom/winlator/cmod/MainActivity;->isDarkMode:Z

    if-eqz v0, :cond_0

    .line 217
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->getWindow()Landroid/view/Window;

    move-result-object v0

    const v1, 0x7f0800f3

    invoke-virtual {v0, v1}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    goto :goto_0

    .line 219
    :cond_0
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->getWindow()Landroid/view/Window;

    move-result-object v0

    const v1, 0x7f0800f2

    invoke-virtual {v0, v1}, Landroid/view/Window;->setBackgroundDrawableResource(I)V

    .line 222
    :goto_0
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->saveEditDialog:Lcom/winlator/cmod/contentdialog/SaveEditDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/contentdialog/SaveEditDialog;->show()V

    .line 223
    return-void
.end method

.method public toggleDrawer()V
    .locals 2

    .line 307
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    const v1, 0x800003

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->isDrawerOpen(I)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 308
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->closeDrawer(I)V

    goto :goto_0

    .line 310
    :cond_0
    iget-object v0, p0, Lcom/winlator/cmod/MainActivity;->drawerLayout:Landroidx/drawerlayout/widget/DrawerLayout;

    invoke-virtual {v0, v1}, Landroidx/drawerlayout/widget/DrawerLayout;->openDrawer(I)V

    .line 312
    :goto_0
    return-void
.end method
