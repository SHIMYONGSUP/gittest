{$WARN SYMBOL_DEPRECATED OFF}
{$WARN IMPLICIT_STRING_CAST OFF}

unit MainUnit;

interface

uses
  Windows, SysUtils, Classes, Dialogs, ExtCtrls, StdCtrls, Controls, Graphics, ComCtrls, IniFiles,
  System.IOUtils;

function CreateThreadMain: Integer;
function LoadIni: Integer;
function GetSHM: Integer;
function GetWatchdogInterval: Integer;
function GetMaxDevice: Integer;
function GetWindowsCaption: Integer;
function GetHideInteval: Integer;
function GetLogPath: Integer;
function GetLogExpire: Integer;
function GetAutoServerOpen: Integer;
//function GetEmsInfo: Integer;
function ReadIniParameter(hogino : Integer) : Boolean;
procedure FormCloseAction;

implementation

uses GlobalVar, hmx.define, hmx.constant, HmxClass, MainForm, HmxFunc;

//------------------------------------------------------------------------------
// 쓰레드 생성
//------------------------------------------------------------------------------
function CreateThreadMain: Integer;
var
    hogino : Integer;
begin
    Result := 0;

    // 동적 배열 크기 설정
    SetLength(gMsgList,     gMaxDev + 1);
    SetLength(gCommLog,     gMaxDev + 1);
    SetLength(gTabSheet,    gMaxDev + 1);
    SetLength(gListBox,     gMaxDev + 1);

    // StartLog 기록
    gStartLog := THmxLog.Create(gPath, COM_LOG_PREFIX+'Start', 'Log', False, True);
    gStartLog.Add('Program Start');

    // 날짜 변경 객체 생성
    gDayOfChange := THmxDayOfChange.Create;

    // 로그 삭제 객체 생성
    gRemoveLogData := THmxRemoveLogData.Create(gPath, '-', faDirectory, gExpire);

    hogino := 1;

    // TAB SHEET 동적 생성
    gTabSheet[hogino] := TTabSheet.Create(fmMain.PageControl1);
    gTabSheet[hogino].PageControl := fmMain.PageControl1;
    gTabSheet[hogino].Name := 'Sheet' + IntToStr(hogino);
    gTabSheet[hogino].Caption := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_CAPTION, '');

    // LIST BOX 동적 생성
    gListBox[hogino] := TListBox.Create(gTabSheet[hogino]);
    gListBox[hogino].Color := $003F3F3F;
    gListBox[hogino].Font.Name := 'Consolas';
    gListBox[hogino].Font.Size := 11;
    gListBox[hogino].Font.Color := clSilver;
    gListBox[hogino].Parent := gTabSheet[hogino];
    gListBox[hogino].Name := 'ListBox' + IntToStr(hogino);
    gListBox[hogino].Align := alClient;
    gListBox[hogino].OnClick := fmMain.ListBoxClick;
    //gListBox[hogino].PopupMenu := fmMain.PopupMenu1;

    // 메시지 출력을 위해 사용
    gIdentifier := 1;
    gWindowMessage := U_WMG_API;
    gWindowHandle := fmMain.Handle;

    // 통신 로그 객체 생성
    gCommLog[hogino] := THmxLog.Create(gPath, Format('%s%3.3d', [COM_LOG_PREFIX, hogino]), 'Log', False, False);

    // 메시지 리스트 객체 생성
    gMsgList[hogino] := THmxMsgList.Create(gListBox[hogino], fmMain.CheckBox1, 100);

    // 포트번호 설정
    fmMain.edPort.Text := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_PARAMETER, '');
end;


//------------------------------------------------------------------------------
// Ini 파일 읽기
//------------------------------------------------------------------------------
function LoadIni: Integer;
begin
    Result := 0;

    // Ini 파일 생성
    gMyIni := TiniFile.Create(INI_COM_FILE);

    if gMyIni = nil
    then Result := 1;
end;


//------------------------------------------------------------------------------
// 공유메모리 초기화
//------------------------------------------------------------------------------
function GetSHM: Integer;
begin
    Result := 0;

    if GetSharedMemory(False) = False
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 워치독 인터벌 설정값 가져오기
//------------------------------------------------------------------------------
function GetWatchdogInterval: Integer;
begin
    Result := 0;

    gWatchdogInterval := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_WATCHDOG_INTERVAL, ''), 0);

    if gWatchdogInterval = 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 장비 대수 설정값 가져오기
//------------------------------------------------------------------------------
function GetMaxDevice: Integer;
begin
    Result := 0;

    gMaxDev := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_MAX_QTY, ''), 0);

    if gMaxDev <= 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 윈도우 Caption 설정값 가져오기
//------------------------------------------------------------------------------
function GetWindowsCaption: Integer;
begin
    Result := 0;

    gCaption := gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_DEV_CAPTION, '');

    if gCaption = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 폼 숨기기 시간 설정값 가져오기
//------------------------------------------------------------------------------
function GetHideInteval: Integer;
begin
    Result := 0;

    gHideInteval := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_HIDE_INTERVAL, ''), 0);

    if gHideInteval < 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 로그 경로 설정값 가져오기
//------------------------------------------------------------------------------
function GetLogPath: Integer;
begin
    Result := 0;

    gPath := String(ReadIni('Logging', 'Path', INI_CFG_FILE));

    if gPath = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// 로그 보존기간 설정값 가져오기
//------------------------------------------------------------------------------
function GetLogExpire: Integer;
begin
    Result := 0;

    gExpire := StrToIntDef(String(ReadIni('Logging', 'Expire', INI_CFG_FILE)), 0);

    if gExpire = 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
function GetAutoServerOpen: Integer;
begin
    Result := 0;

    if gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_AUTO_SERVER_OPEN, '') = 'Y'
    then gAutoServerOpen := True
    else gAutoServerOpen := False;

    if gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_AUTO_SERVER_OPEN, '') = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// INI Parameter 읽기
//------------------------------------------------------------------------------
function ReadIniParameter(hogino : Integer) : Boolean;
var
    sCaption, sType, sSleep, sTimeOut, sCommValue, sDisplay : string;
begin
    Result := False;

    sCaption   := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_CAPTION,   '');
    sType      := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_TYPE,      '');
    sSleep     := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_SLEEP,     '');
    sTimeOut   := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_TIMEOUT,   '');
    sCommValue := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_PARAMETER, '');
    sDisplay   := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_DISPLAY,   '');

    try
        if sCaption = ''
        then raise Exception.Create('INI_CAPTION Not Found.');

        if sType = ''
        then raise Exception.Create('INI_TYPE Not Found.');

        if sSleep = ''
        then raise Exception.Create('INI_SLEEP Not Found.');

        if sTimeOut = ''
        then raise Exception.Create('INI_TIMEOUT Not Found.');

        //if sCommValue = ''
        //then raise Exception.Create('INI_PARAMETER Not Found.');

        if sDisplay = ''
        then raise Exception.Create('INI_DISPLAY Not Found.');

        Result := True;
    except on e: Exception do
        begin
            ShowMessage(e.Message);
            exit;
        end;
    end;
end;

//------------------------------------------------------------------------------
// 폼 종료시 메모리 해제
//------------------------------------------------------------------------------
procedure FormCloseAction;
var
    hogino : Integer;
begin
    // 객체 메모리 해제
    for hogino := 0 to gMaxDev do
    begin
        FreeAndNil(gListBox[hogino]);
        FreeAndNil(gTabSheet[hogino]);

        FreeAndNil(gMsgList[hogino]);
        FreeAndNil(gCommLog[hogino]);
    end;

    FreeAndNil(gStartLog);
    FreeAndNil(gEmsIniFile);
    FreeAndNil(gEmsKeyList);
    FreeAndNil(gEmsStrList);

    // 동적 배열 메모리 해제
    gTabSheet := nil;
    gListBox := nil;
    gMsgList := nil;
    gCommLog := nil;
    gStartLog := nil;

    FreeAndNil(gDayOfChange);
    FreeAndNil(gRemoveLogData);

    FreeAndNil(gMyIni);
    FreeAndNil(gCriticalSection);
end;


end.
