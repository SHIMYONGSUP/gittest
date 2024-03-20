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
// ������ ����
//------------------------------------------------------------------------------
function CreateThreadMain: Integer;
var
    hogino : Integer;
begin
    Result := 0;

    // ���� �迭 ũ�� ����
    SetLength(gMsgList,     gMaxDev + 1);
    SetLength(gCommLog,     gMaxDev + 1);
    SetLength(gTabSheet,    gMaxDev + 1);
    SetLength(gListBox,     gMaxDev + 1);

    // StartLog ���
    gStartLog := THmxLog.Create(gPath, COM_LOG_PREFIX+'Start', 'Log', False, True);
    gStartLog.Add('Program Start');

    // ��¥ ���� ��ü ����
    gDayOfChange := THmxDayOfChange.Create;

    // �α� ���� ��ü ����
    gRemoveLogData := THmxRemoveLogData.Create(gPath, '-', faDirectory, gExpire);

    hogino := 1;

    // TAB SHEET ���� ����
    gTabSheet[hogino] := TTabSheet.Create(fmMain.PageControl1);
    gTabSheet[hogino].PageControl := fmMain.PageControl1;
    gTabSheet[hogino].Name := 'Sheet' + IntToStr(hogino);
    gTabSheet[hogino].Caption := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_CAPTION, '');

    // LIST BOX ���� ����
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

    // �޽��� ����� ���� ���
    gIdentifier := 1;
    gWindowMessage := U_WMG_API;
    gWindowHandle := fmMain.Handle;

    // ��� �α� ��ü ����
    gCommLog[hogino] := THmxLog.Create(gPath, Format('%s%3.3d', [COM_LOG_PREFIX, hogino]), 'Log', False, False);

    // �޽��� ����Ʈ ��ü ����
    gMsgList[hogino] := THmxMsgList.Create(gListBox[hogino], fmMain.CheckBox1, 100);

    // ��Ʈ��ȣ ����
    fmMain.edPort.Text := gMyIni.ReadString(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_PARAMETER, '');
end;


//------------------------------------------------------------------------------
// Ini ���� �б�
//------------------------------------------------------------------------------
function LoadIni: Integer;
begin
    Result := 0;

    // Ini ���� ����
    gMyIni := TiniFile.Create(INI_COM_FILE);

    if gMyIni = nil
    then Result := 1;
end;


//------------------------------------------------------------------------------
// �����޸� �ʱ�ȭ
//------------------------------------------------------------------------------
function GetSHM: Integer;
begin
    Result := 0;

    if GetSharedMemory(False) = False
    then Result := 1;
end;

//------------------------------------------------------------------------------
// ��ġ�� ���͹� ������ ��������
//------------------------------------------------------------------------------
function GetWatchdogInterval: Integer;
begin
    Result := 0;

    gWatchdogInterval := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_WATCHDOG_INTERVAL, ''), 0);

    if gWatchdogInterval = 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// ��� ��� ������ ��������
//------------------------------------------------------------------------------
function GetMaxDevice: Integer;
begin
    Result := 0;

    gMaxDev := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_MAX_QTY, ''), 0);

    if gMaxDev <= 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// ������ Caption ������ ��������
//------------------------------------------------------------------------------
function GetWindowsCaption: Integer;
begin
    Result := 0;

    gCaption := gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_DEV_CAPTION, '');

    if gCaption = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// �� ����� �ð� ������ ��������
//------------------------------------------------------------------------------
function GetHideInteval: Integer;
begin
    Result := 0;

    gHideInteval := StrToIntDef(gMyIni.ReadString(INI_SEC_DEVICE, INI_IDN_HIDE_INTERVAL, ''), 0);

    if gHideInteval < 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// �α� ��� ������ ��������
//------------------------------------------------------------------------------
function GetLogPath: Integer;
begin
    Result := 0;

    gPath := String(ReadIni('Logging', 'Path', INI_CFG_FILE));

    if gPath = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// �α� �����Ⱓ ������ ��������
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
// INI Parameter �б�
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
// �� ����� �޸� ����
//------------------------------------------------------------------------------
procedure FormCloseAction;
var
    hogino : Integer;
begin
    // ��ü �޸� ����
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

    // ���� �迭 �޸� ����
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
