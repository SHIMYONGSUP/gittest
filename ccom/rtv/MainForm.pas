unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Forms, Dialogs, Controls, Menus, ComCtrls,
  ExtCtrls, StdCtrls, Classes, Graphics,
  HmxClass, HmxFunc, hmx.define, hmx.constant, IdContext, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer;

type

  TfmMain = class(TForm)
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    TimerWatchdog: TTimer;
    miExit: TMenuItem;
    Memo: TMemo;
    Cancel1: TMenuItem;
    PageControl1: TPageControl;
    CheckBox1: TCheckBox;
    TimerHide: TTimer;
    PopupMenu1: TPopupMenu;
    ClearMessage1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TimerWatchdogTimer(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ThreadTerminate(Sender : TObject);
    procedure PageControl1DrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure CheckBox1Click(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
    procedure ClearMessage1Click(Sender: TObject);
  private
    procedure ReceiveMessage(var Msg: TMessage); message U_WMG_BCR;
    procedure DisplayMessage(Msg: string; Identifier: integer);
  end;

var
  	fmMain: TfmMain;
    g_exit : Boolean;
implementation

uses GlobalVar, MainUnit;

{$R *.DFM}

//------------------------------------------------------------------------------
// Form ���۽�  ----------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.FormCreate(Sender: TObject);
begin
    TimerWatchdog.Enabled := False;

    try
        // Ini ���� �б�
        if LoadIni <> 0
        then raise Exception.Create('LoadIni Fails!');

        // �����޸� �ʱ�ȭ
        if GetSHM <> 0
        then raise Exception.Create('GetSHM Fails!');

        // ������ Caption ������ ��������
        if GetWindowsCaption <> 0
        then raise Exception.Create('GetWindowsCaption Fails!');

        // �� ����� �ð� ������ ��������
        if GetHideInteval <> 0
        then raise Exception.Create('GetHideInteval Fails!');

        // ��� ��� ������ ��������
        if GetMaxDevice <> 0
        then raise Exception.Create('GetMaxDevice Fails!');

        // ��ġ�� ���͹� ������ ��������
        if GetWatchdogInterval <> 0
        then raise Exception.Create('GetWatchdogInterval Fails!');

        // �α� ��� ������ ��������
        if GetLogPath <> 0
        then raise Exception.Create('GetLogPath Fails!');

        // �α� �����Ⱓ ������ ��������
        if GetLogExpire <> 0
        then raise Exception.Create('GetLogExpire Fails!');

        // ������ ����
        if CreateThreadMain <> 0
        then raise Exception.Create('CreateThreadMain Fails!');

        // ������ Caption ����
        Application.Title := gCaption;
        TrayIcon.Hint  := gCaption;

        // �� ����� �ð� ���� (���� 0���� Ŭ���� ���� �����)
        if gHideInteval > 0
        then begin
            TimerHide.Interval := gHideInteval;
            TimerHide.Enabled := True;
        end;

        // ��ġ�� Ÿ�̸� ����
        TimerWatchdog.Interval := gWatchdogInterval;
        TimerWatchdog.Enabled := True;
    except on E: Exception do
        begin
            ShowMessage(e.Message);
            ExitProcess(0);
            Close;
        end;
    end;
end;

//------------------------------------------------------------------------------
// Form �����  ----------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    FormCloseAction;

    // ���� �ݰ� ���� �ڿ��� �޸𸮿��� ����
    Action := caFree;
end;

//------------------------------------------------------------------------------
// Tread �����  ---------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.ThreadTerminate(Sender : TObject);
begin
    // Thread ����� - 1
    Dec(gThreadRemaining);

    // ������ ���� ���·� ����
    gThread[THmxThread(Sender).Identifier].Status := U_SYS_THR_DEAD;

    // ��� ������ ����� �� Close �Ѵ�.
    if (gThreadRemaining = 0) and (gThread[THmxThread(Sender).Identifier].Restart = False)
    then Close;
end;

//------------------------------------------------------------------------------
procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    // ��� �����尡 ����� �����̸� ���� Close �Ѵ�.
    if gThreadRemaining = 0
    then begin
        CanClose := True;
        g_exit := True;
    end
    else begin
        CanClose := False;
        Hide;
    end;
end;

//------------------------------------------------------------------------------
// ������ ������� �ʿ��� ��� Ÿ�̸ӿ��� �ش� �������� ���¸� Ȯ���ϰ�
// �����尡 ����� �ϱ����� ����� ��쿡�� �����带 �ٽ� �����Ѵ�.
//------------------------------------------------------------------------------
procedure TfmMain.TimerWatchdogTimer(Sender: TObject);
var
    my_i, hogi_no : Integer;
begin

    TimerWatchdog.Enabled := False;

    if g_exit then Exit;

    // �����尡 ��� ����� ���
    if gThreadRemaining = 0 then exit;

    try
        // 2018.10.07 JSB �߰�
        // ������ �޽��� ���� �ʱ�ȭ
        gThreadMsg.Clear;

        WatchDogThread;

        // 2018.10.07 JSB �߰�
        // �����峻���� �޽��� �Էµ� ��� �޽����� ����Ѵ�
        if gThreadMsg.Count = 0
        then exit;

        for my_i := 0 to gThreadMsg.Count - 1 do
        begin
            hogi_no := StrToIntDef(Copy(gThreadMsg.Strings[my_i], 1, 1), 1);
            DisplayMessage(gThreadMsg.Strings[my_i], hogi_no);
        end;
    finally
        TimerWatchdog.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.miExitClick(Sender: TObject);
var
    hogino : Integer;
begin
    for hogino := 1 to gMaxDev do
    begin
        if gThread[hogino].Status = U_SYS_THR_ALIVE
        then begin
            gThread[hogino].Restart := False;     // ���α׷� �����ϴ� ���
            gThread[hogino].Status := U_SYS_THR_KILL;
            gThread[hogino].Terminate;
        end;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.TrayIconDblClick(Sender: TObject);
begin
    Show;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ListBoxClick(Sender: TObject);
begin
    Memo.Text := TListBox(Sender).Items.Strings[TListBox(Sender).ItemIndex];
end;

//------------------------------------------------------------------------------
// �޽����� ListBox�� ǥ��
//------------------------------------------------------------------------------
procedure TfmMain.DisplayMessage(Msg: string; Identifier: integer);
begin
    gMsgList[Identifier].Add(Msg);
    gCommLog[Identifier].AddPerHour(Msg);
end;

//------------------------------------------------------------------------------
// Window �޽����� �޾Ƽ� DisplayMessage ȣ��
//------------------------------------------------------------------------------
procedure TfmMain.ReceiveMessage(var Msg: TMessage);
var
    buffer : ^String;
begin
    buffer := Pointer(Msg.WParam);

    try
        DisplayMessage(buffer^, Msg.LParam);
    finally
        Dispose(buffer);
    end;
end;

//------------------------------------------------------------------------------
// ����Ʈ�ڽ� �޼��� �����
//------------------------------------------------------------------------------
procedure TfmMain.ClearMessage1Click(Sender: TObject);
begin
    gListBox[PageControl1.TabIndex+1].Clear;
end;


//------------------------------------------------------------------------------
// TabSheet ���� ����
//------------------------------------------------------------------------------
procedure TfmMain.PageControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
    with Control.Canvas do
    begin
        if Active
        then begin
            Brush.Color := clBlue;
            Rectangle(Rect);
            Font.Color := clWhite;
            TextOut(Rect.Left+4, Rect.Top+3,(Control as TPageControl).Pages[TabIndex].Caption);
        end
        else begin
            Brush.Color := clBtnFace;
            Font.Color := clBtnText;
            TextOut(Rect.Left+4, Rect.Top+3,(Control as TPageControl).Pages[TabIndex].Caption);
        end;
    end;

end;

//------------------------------------------------------------------------------
// CheckBox ���� ����
//------------------------------------------------------------------------------
procedure TfmMain.CheckBox1Click(Sender: TObject);
begin
    if TCheckBox(Sender).Checked = True
    then begin
        TCheckBox(Sender).Font.Color := clBlack;
        TCheckBox(Sender).Color := clBtnFace;
    end
    else begin
        TCheckBox(Sender).Font.Color := clBlack;
        TCheckBox(Sender).Color := clSilver;
    end;
end;


procedure TfmMain.TimerHideTimer(Sender: TObject);
begin
    TimerHide.Enabled := False;
    Hide;
end;

end.
