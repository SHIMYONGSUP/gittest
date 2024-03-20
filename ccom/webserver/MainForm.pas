unit MainForm;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, MainUnit, System.IOUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.AppEvnts, Vcl.StdCtrls, IdHTTPWebBrokerBridge, IdGlobal, Web.HTTPApp,
  Vcl.ExtCtrls, Vcl.ComCtrls, GlobalVar, GlobalFnc, hmx.constant, Vcl.Menus;

type
  TfmMain = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    ApplicationEvents1: TApplicationEvents;
    ButtonOpenBrowser: TButton;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Label2: TLabel;
    edPort: TEdit;
    Panel2: TPanel;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    TimerWatchdog: TTimer;
    TimerHide: TTimer;
    TrayIcon: TTrayIcon;
    pmIcon: TPopupMenu;
    miExit: TMenuItem;
    N2: TMenuItem;
    miHide: TMenuItem;
    miShow: TMenuItem;
    PopupMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    Cancel1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ClearMessage1: TMenuItem;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
  private
    FServer: TIdHTTPWebBrokerBridge;
    procedure StartServer;
    procedure ReceiveMessage(var AMsg: TMessage); message U_WMG_WSV;
    procedure AppendMessage(AMsg: string; Identifier: integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows, Winapi.ShellApi,
{$ENDIF}
  System.Generics.Collections;

//------------------------------------------------------------------------------
procedure TfmMain.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
    ButtonStart.Enabled := not FServer.Active;
    ButtonStop.Enabled := FServer.Active;
    edPort.Enabled := not FServer.Active;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ButtonOpenBrowserClick(Sender: TObject);
{$IFDEF MSWINDOWS}
var
    LURL: string;
{$ENDIF}
begin
    StartServer;
{$IFDEF MSWINDOWS}
    LURL := Format('http://localhost:%s', [edPort.Text]) + '/WORK/ALL';
    ShellExecute(0, nil, PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
{$ENDIF}
end;

//------------------------------------------------------------------------------
procedure TfmMain.ButtonStartClick(Sender: TObject);
begin
  StartServer;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ButtonStopClick(Sender: TObject);
begin
    FServer.Active := False;
    FServer.Bindings.Clear;
end;

//------------------------------------------------------------------------------
procedure TfmMain.FormCreate(Sender: TObject);
begin
    FServer := TIdHTTPWebBrokerBridge.Create(Self);

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

        // �ڵ� ���� ����
        if GetAutoServerOpen <> 0
        then raise Exception.Create('GetAutoServerOpen Fails!');

        // ������ ����
        if CreateThreadMain <> 0
        then raise Exception.Create('CreateThreadMain Fails!');

        // ������ Caption ����
        Application.Title := gCaption;
        TrayIcon.Hint := gCaption;
        fmMain.Caption := gCaption + ' [ ver 1.0 ]';

        // �� ����� �ð� ���� (���� 0���� Ŭ���� ���� �����)
        if gHideInteval > 0
        then begin
            TimerHide.Interval := gHideInteval;
            TimerHide.Enabled := True;
        end;

        if gAutoServerOpen = True
        then StartServer;

        // ����ð�
        StatusBar1.Panels[1].Text := 'Build Time: ' + FormatDateTime('YYYY/MM/DD HH:NN:SS', TFile.GetLastWriteTime(Application.ExeName));

        // ��ġ�� Ÿ�̸� ����
        TimerWatchdog.Interval := gWatchdogInterval;

        // �޽��� ����� ���� ���
        gIdentifier := 1;
        gWindowMessage := U_WMG_WSV;
        gWindowHandle := fmMain.Handle;
    except on e: Exception do
        begin
            ShowMessage(e.Message);
            ExitProcess(0);
            Close;
        end;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.StartServer;
begin
    if not FServer.Active then
    begin
        FServer.Bindings.Clear;
        FServer.DefaultPort := StrToInt(edPort.Text);
        FServer.Active := True;

        DisplayMessage('StartServer');
    end;
end;

//------------------------------------------------------------------------------
// �޽����� ListBox�� ǥ��
//------------------------------------------------------------------------------
procedure TfmMain.AppendMessage(AMsg: string; Identifier: integer);
begin
    gMsgList[gMaxDev].Add(AMsg);
    gCommLog[gMaxDev].AddPerHour(AMsg);
end;

//------------------------------------------------------------------------------
// Window �޽����� �޾Ƽ� DisplayMessage ȣ��
//------------------------------------------------------------------------------
procedure TfmMain.ReceiveMessage(var AMsg: TMessage);
var
    buffer : ^String;
begin
    buffer := Pointer(AMsg.WParam);

    try
        AppendMessage(buffer^, AMsg.LParam);
    finally
        Dispose(buffer);
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.ListBoxClick(Sender: TObject);
begin
    Memo1.Text := TListBox(Sender).Items.Strings[TListBox(Sender).ItemIndex];
end;


end.
