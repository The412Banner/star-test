.class public final synthetic Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;

.field public final synthetic f$1:Landroid/app/Activity;


# direct methods
.method public synthetic constructor <init>(Lcom/winlator/cmod/core/DownloadProgressDialog;Landroid/app/Activity;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;

    iput-object p2, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$1:Landroid/app/Activity;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    .line 0
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$0:Lcom/winlator/cmod/core/DownloadProgressDialog;

    invoke-virtual {v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->close()V

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda2;->f$1:Landroid/app/Activity;

    check-cast v0, Lcom/winlator/cmod/MainActivity;

    invoke-virtual {v0}, Lcom/winlator/cmod/MainActivity;->doPermissionsFlow()V

    return-void
.end method
