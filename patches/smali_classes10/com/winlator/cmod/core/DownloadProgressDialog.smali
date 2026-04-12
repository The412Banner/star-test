.class public Lcom/winlator/cmod/core/DownloadProgressDialog;
.super Ljava/lang/Object;
.source "DownloadProgressDialog.java"


# instance fields
.field private final activity:Landroid/app/Activity;

.field private dialog:Landroid/app/Dialog;


# direct methods
.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    .param p1, "activity"    # Landroid/app/Activity;

    .line 18
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 19
    iput-object p1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->activity:Landroid/app/Activity;

    .line 20
    return-void
.end method

.method private create()V
    .locals 4

    .line 23
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    if-eqz v0, :cond_0

    return-void

    .line 24
    :cond_0
    new-instance v0, Landroid/app/Dialog;

    iget-object v1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->activity:Landroid/app/Activity;

    const v2, 0x1030011

    invoke-direct {v0, v1, v2}, Landroid/app/Dialog;-><init>(Landroid/content/Context;I)V

    iput-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    .line 25
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->requestWindowFeature(I)Z

    .line 26
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->setCancelable(Z)V

    .line 27
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->setCanceledOnTouchOutside(Z)V

    .line 28
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v1, 0x7f0c004d

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->setContentView(I)V

    .line 30
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    invoke-virtual {v0}, Landroid/app/Dialog;->getWindow()Landroid/view/Window;

    move-result-object v0

    .line 31
    .local v0, "window":Landroid/view/Window;
    if-eqz v0, :cond_1

    .line 32
    const/16 v1, 0x10

    invoke-virtual {v0, v1}, Landroid/view/Window;->clearFlags(I)V

    .line 33
    const/16 v1, 0x8

    invoke-virtual {v0, v1}, Landroid/view/Window;->clearFlags(I)V

    .line 35
    const/4 v1, -0x1

    invoke-virtual {v0, v1, v1}, Landroid/view/Window;->setLayout(II)V

    new-instance v2, Landroid/graphics/drawable/ColorDrawable;

    const/4 v3, 0x0

    invoke-direct {v2, v3}, Landroid/graphics/drawable/ColorDrawable;-><init>(I)V

    invoke-virtual {v0, v2}, Landroid/view/Window;->setBackgroundDrawable(Landroid/graphics/drawable/Drawable;)V

    :cond_1
    return-void
.end method

.method static synthetic lambda$show$0(Ljava/lang/Runnable;Landroid/view/View;)V
    .locals 0
    .param p0, "onCancelCallback"    # Ljava/lang/Runnable;
    .param p1, "v"    # Landroid/view/View;

    .line 58
    invoke-interface {p0}, Ljava/lang/Runnable;->run()V

    return-void
.end method


# virtual methods
.method public close()V
    .locals 1

    .line 73
    :try_start_0
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    if-eqz v0, :cond_0

    .line 74
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    invoke-virtual {v0}, Landroid/app/Dialog;->dismiss()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 77
    :catch_0
    move-exception v0

    :cond_0
    :goto_0
    nop

    .line 78
    return-void
.end method

.method public closeOnUiThread()V
    .locals 2

    .line 81
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->activity:Landroid/app/Activity;

    new-instance v1, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0}, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda0;-><init>(Lcom/winlator/cmod/core/DownloadProgressDialog;)V

    invoke-virtual {v0, v1}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    .line 82
    return-void
.end method

.method public isShowing()Z
    .locals 1

    .line 85
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    invoke-virtual {v0}, Landroid/app/Dialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public setProgress(I)V
    .locals 3
    .param p1, "progress"    # I

    .line 65
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    if-nez v0, :cond_0

    return-void

    .line 66
    :cond_0
    const/4 v0, 0x0

    const/16 v1, 0x64

    invoke-static {p1, v0, v1}, Lcom/winlator/cmod/math/Mathf;->clamp(III)I

    move-result p1

    .line 67
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v1, 0x7f090073

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setProgress(I)V

    .line 68
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v1, 0x7f090160

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Installing... "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "%"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 69
    return-void
.end method

.method public show()V
    .locals 1

    .line 38
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->show(Ljava/lang/Runnable;)V

    .line 39
    return-void
.end method

.method public show(I)V
    .locals 1
    .param p1, "textResId"    # I

    .line 42
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->show(ILjava/lang/Runnable;)V

    .line 43
    return-void
.end method

.method public show(ILjava/lang/Runnable;)V
    .locals 3
    .param p1, "textResId"    # I
    .param p2, "onCancelCallback"    # Ljava/lang/Runnable;

    .line 50
    invoke-virtual {p0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    .line 51
    :cond_0
    invoke-virtual {p0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->close()V

    .line 52
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    if-nez v0, :cond_1

    invoke-direct {p0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->create()V

    .line 54
    :cond_1
    if-lez p1, :cond_2

    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v1, 0x7f09017c

    invoke-virtual {v0, v1}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(I)V

    .line 56
    :cond_2
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/winlator/cmod/core/DownloadProgressDialog;->setProgress(I)V

    .line 57
    if-eqz p2, :cond_3

    .line 58
    iget-object v1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v2, 0x7f09000d

    invoke-virtual {v1, v2}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;

    move-result-object v1

    new-instance v2, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda1;

    invoke-direct {v2, p2}, Lcom/winlator/cmod/core/DownloadProgressDialog$$ExternalSyntheticLambda1;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {v1, v2}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 59
    iget-object v1, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    const v2, 0x7f090093

    invoke-virtual {v1, v2}, Landroid/app/Dialog;->findViewById(I)Landroid/view/View;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/view/View;->setVisibility(I)V

    .line 61
    :cond_3
    iget-object v0, p0, Lcom/winlator/cmod/core/DownloadProgressDialog;->dialog:Landroid/app/Dialog;

    invoke-virtual {v0}, Landroid/app/Dialog;->show()V

    .line 62
    return-void
.end method

.method public show(Ljava/lang/Runnable;)V
    .locals 1
    .param p1, "onCancelCallback"    # Ljava/lang/Runnable;

    .line 46
    const/4 v0, 0x0

    invoke-virtual {p0, v0, p1}, Lcom/winlator/cmod/core/DownloadProgressDialog;->show(ILjava/lang/Runnable;)V

    .line 47
    return-void
.end method
