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
        // Ini 파일 읽기
        if LoadIni <> 0
        then raise Exception.Create('LoadIni Fails!');

        // 공유메모리 초기화
        if GetSHM <> 0
        then raise Exception.Create('GetSHM Fails!');

        // 윈도우 Caption 설정값 가져오기
        if GetWindowsCaption <> 0
        then raise Exception.Create('GetWindowsCaption Fails!');

        // 폼 숨기기 시간 설정값 가져오기
        if GetHideInteval <> 0
        then raise Exception.Create('GetHideInteval Fails!');

        // 장비 대수 설정값 가져오기
        if GetMaxDevice <> 0
        then raise Exception.Create('GetMaxDevice Fails!');

        // 워치독 인터벌 설정값 가져오기
        if GetWatchdogInterval <> 0
        then raise Exception.Create('GetWatchdogInterval Fails!');

        // 로그 경로 설정값 가져오기
        if GetLogPath <> 0
        then raise Exception.Create('GetLogPath Fails!');

        // 로그 보존기간 설정값 가져오기
        if GetLogExpire <> 0
        then raise Exception.Create('GetLogExpire Fails!');

        // 자동 서버 오픈
        if GetAutoServerOpen <> 0
        then raise Exception.Create('GetAutoServerOpen Fails!');

        // 쓰레드 생성
        if CreateThreadMain <> 0
        then raise Exception.Create('CreateThreadMain Fails!');

        // 윈도우 Caption 설정
        Application.Title := gCaption;
        TrayIcon.Hint := gCaption;
        fmMain.Caption := gCaption + ' [ ver 1.0 ]';

        // 폼 숨기기 시간 설정 (값이 0보다 클때만 폼을 숨긴다)
        if gHideInteval > 0
        then begin
            TimerHide.Interval := gHideInteval;
            TimerHide.Enabled := True;
        end;

        if gAutoServerOpen = True
        then StartServer;

        // 빌드시간
        StatusBar1.Panels[1].Text := 'Build Time: ' + FormatDateTime('YYYY/MM/DD HH:NN:SS', TFile.GetLastWriteTime(Application.ExeName));

        // 워치독 타이머 시작
        TimerWatchdog.Interval := gWatchdogInterval;

        // 메시지 출력을 위해 사용
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
// 메시지를 ListBox에 표시
//------------------------------------------------------------------------------
procedure TfmMain.AppendMessage(AMsg: string; Identifier: integer);
begin
    gMsgList[gMaxDev].Add(AMsg);
    gCommLog[gMaxDev].AddPerHour(AMsg);
end;

//------------------------------------------------------------------------------
// Window 메시지를 받아서 DisplayMessage 호출
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
