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
// Form 시작시  ----------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.FormCreate(Sender: TObject);
begin
    TimerWatchdog.Enabled := False;

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

        // 쓰레드 생성
        if CreateThreadMain <> 0
        then raise Exception.Create('CreateThreadMain Fails!');

        // 윈도우 Caption 설정
        Application.Title := gCaption;
        TrayIcon.Hint  := gCaption;

        // 폼 숨기기 시간 설정 (값이 0보다 클때만 폼을 숨긴다)
        if gHideInteval > 0
        then begin
            TimerHide.Interval := gHideInteval;
            TimerHide.Enabled := True;
        end;

        // 워치독 타이머 시작
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
// Form 종료시  ----------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    FormCloseAction;

    // 폼을 닫고 폼의 자원을 메모리에서 해제
    Action := caFree;
end;

//------------------------------------------------------------------------------
// Tread 종료시  ---------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfmMain.ThreadTerminate(Sender : TObject);
begin
    // Thread 종료시 - 1
    Dec(gThreadRemaining);

    // 쓰레드 종료 상태로 설정
    gThread[THmxThread(Sender).Identifier].Status := U_SYS_THR_DEAD;

    // 모든 쓰레드 종료시 폼 Close 한다.
    if (gThreadRemaining = 0) and (gThread[THmxThread(Sender).Identifier].Restart = False)
    then Close;
end;

//------------------------------------------------------------------------------
procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    // 모든 쓰레드가 종료된 상태이면 폼을 Close 한다.
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
// 쓰레드 재시작이 필요한 경우 타이머에서 해당 쓰레드의 상태를 확인하고
// 쓰레드가 재시작 하기위해 종료된 경우에는 쓰레드를 다시 생성한다.
//------------------------------------------------------------------------------
procedure TfmMain.TimerWatchdogTimer(Sender: TObject);
var
    my_i, hogi_no : Integer;
begin

    TimerWatchdog.Enabled := False;

    if g_exit then Exit;

    // 쓰레드가 모두 종료된 경우
    if gThreadRemaining = 0 then exit;

    try
        // 2018.10.07 JSB 추가
        // 쓰레드 메시지 변수 초기화
        gThreadMsg.Clear;

        WatchDogThread;

        // 2018.10.07 JSB 추가
        // 쓰레드내에서 메시지 입력된 경우 메시지를 출력한다
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
            gThread[hogino].Restart := False;     // 프로그램 종료하는 경우
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
// 메시지를 ListBox에 표시
//------------------------------------------------------------------------------
procedure TfmMain.DisplayMessage(Msg: string; Identifier: integer);
begin
    gMsgList[Identifier].Add(Msg);
    gCommLog[Identifier].AddPerHour(Msg);
end;

//------------------------------------------------------------------------------
// Window 메시지를 받아서 DisplayMessage 호출
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
// 리스트박스 메세지 지우기
//------------------------------------------------------------------------------
procedure TfmMain.ClearMessage1Click(Sender: TObject);
begin
    gListBox[PageControl1.TabIndex+1].Clear;
end;


//------------------------------------------------------------------------------
// TabSheet 색상 변경
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
// CheckBox 색상 변경
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
