{$WARN SYMBOL_DEPRECATED OFF}
{$WARN IMPLICIT_STRING_CAST OFF}
unit MainUnit;

interface

uses
  Windows, SysUtils, Classes, Dialogs, ExtCtrls, StdCtrls, Controls, Graphics,
  ComCtrls, IniFiles, Contnrs;

function LoadIni: Integer;
function GetSHM: Integer;
function SetDbConnetStat: Integer;
function GetWatchdogInterval: Integer;
function GetMaxDevice: Integer;
function GetWindowsCaption: Integer;
function GetHideInteval: Integer;
function GetPosRange: Integer;
function GetPassCount: Integer;
function GetLogPath: Integer;
function GetLogExpire: Integer;
function CreateThreadMain: Integer;
function CreateThread(hogino : Integer) : Boolean;
function ReadIniParameter(hogino : Integer) : Boolean;
function GetSttnInfo: Integer;
procedure WatchdogThread;
procedure FormCloseAction;

implementation

uses GlobalVar, HmxClass, MainForm, hmx.Control,
  hmx.constant, hmx.define, HmxFunc;


//------------------------------------------------------------------------------
// Ini ���� �б�
//------------------------------------------------------------------------------
function LoadIni: Integer;
begin
    Result := 0;

    // Ini ���� ����
    gMyIni := TiniFile.Create(INI_CTL_FILE);

    if gMyIni = nil
    then Result := 1;
end;

//------------------------------------------------------------------------------
// �����޸� �ʱ�ȭ
//------------------------------------------------------------------------------
function GetSHM: Integer;
begin
    Result := 0;

    if GetSharedMemory(True) = False
    then if CreateSharedMemory(True) = False
    then Result := 1;
end;

//------------------------------------------------------------------------------
// DB ���� ���� ����
//------------------------------------------------------------------------------
function SetDbConnetStat: Integer;
begin
    // DB ���ӻ��¸� �����޸𸮿� ����.
    //shmptr^.dbconn[U_DTB_CNC_CTL] := DModule.DBMS.Connected;

    Result := 0;
end;

//------------------------------------------------------------------------------
// ��ġ�� ���͹� ������ ��������
//------------------------------------------------------------------------------
function GetWatchdogInterval: Integer;
begin
    Result := 0;

    gWatchdogInterval := StrToIntDef(String(ReadIni(INI_SEC_DEVICE, INI_IDN_WATCHDOG_INTERVAL, INI_CTL_FILE)), 0);

    if gWatchdogInterval = 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// ��� ��� ������ ��������
//------------------------------------------------------------------------------
function GetMaxDevice: Integer;
begin
    Result := 0;

    gMaxDev := StrToIntDef(String(ReadIni(INI_SEC_DEVICE, INI_IDN_MAX_QTY, INI_CTL_FILE)), 0);

    if gMaxDev <= 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// ������ Caption ������ ��������
//------------------------------------------------------------------------------
function GetWindowsCaption: Integer;
begin
    Result := 0;

    gCaption := String(ReadIni(INI_SEC_DEVICE, INI_IDN_DEV_CAPTION, INI_CTL_FILE));

    if gCaption = ''
    then Result := 1;
end;

//------------------------------------------------------------------------------
// �� ����� �ð� ������ ��������
//------------------------------------------------------------------------------
function GetHideInteval: Integer;
begin
    Result := 0;

    gHideInteval := StrToIntDef(String(ReadIni(INI_SEC_DEVICE, INI_IDN_HIDE_INTERVAL, INI_CTL_FILE)), 0);

    if gHideInteval < 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// Pos Range ������ ��������
//------------------------------------------------------------------------------
function GetPosRange: Integer;
begin
    Result := 0;

    gPosRange := StrToIntDef(String(ReadIni(INI_SEC_DEVICE, INI_IDN_POS_RANGE, INI_CTL_FILE)), 0);

    if gPosRange < 0
    then Result := 1;
end;

//------------------------------------------------------------------------------
// Pass Count ������ ��������
//------------------------------------------------------------------------------
function GetPassCount: Integer;
begin
    Result := 0;

    gPassCount := StrToIntDef(String(ReadIni(INI_SEC_DEVICE, INI_IDN_PASS_COUNT, INI_CTL_FILE)), 0);

    if gPassCount < 0
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
// �����̼� �� ��������
//------------------------------------------------------------------------------
function GetSttnInfo: Integer;
var
    sList, tList, rList : TStringList;
    my_i, idx : integer;
    grp_no: Integer;
begin
    Result := 1;

    if not FileExists(U_SYS_ROOT + '\File\RTV_STATION.CSV')
    then Exit;

    sList := TStringList.Create;
    tList := TStringList.Create;
    rList := TStringList.Create;

    try
        sList.LoadFromFile(U_SYS_ROOT + '\File\RTV_STATION.CSV');

        if sList.Count = 0
        then Exit;

        // �����̼� �ʱ�ȭ
        FillChar(gSetMaxSttn, SizeOf(gSetMaxSttn), 0);

        {$REGION 'â�� MAX Station'}
        for grp_no := 1 to U_MAX_GRP do
        begin
            for my_i := 0 to sList.Count-1 do
            begin
                tList.Text := StringReplace(sList[my_i], ',', U_CTC_CR, [rfReplaceAll]);

                // â���ȣ�� �ٸ��� Continue
                if grp_no <> StrToIntDef(tList[0], 0)
                then Continue;

                // �����̼� Count ����
                Inc(gSetMaxSttn[grp_no]);
            end;
        end;
        {$ENDREGION}

        {$REGION 'â�� �����̼� ���� �Է�'}
        for grp_no := 1 to U_MAX_GRP do
        begin
            // â�� �����̼����� ������ ����
            SetLength(gSttnInfo[grp_no], (gSetMaxSttn[grp_no] + 1));
            idx := 0;
            for my_i := 0 to sList.Count-1 do
            begin
                if my_i = 0 then Continue;

                tList.Text := StringReplace(sList[my_i], ',', U_CTC_CR, [rfReplaceAll]);

                // â���ȣ�� �ٸ��� Continue
                if grp_no <> StrToIntDef(tList[0], 0)
                then Continue;

                Inc(idx);
                gSttnInfo[grp_no][idx].group_no     := grp_no;
                gSttnInfo[grp_no][idx].station_no   := StrToIntDef(tList[1], 0);
                gSttnInfo[grp_no][idx].position     := StrToIntDef(tList[2], 0);
                gSttnInfo[grp_no][idx].station_type := tList[3];
                gSttnInfo[grp_no][idx].priority     := StrToIntDef(tList[4], 0);
                gSttnInfo[grp_no][idx].possible     := '0#'+ tList[5];
            end;
        end;
        {$ENDREGION}
    finally
        Result := 0;
        sList.Free;
        tList.Free;
        rList.Free;
    end;
end;

//------------------------------------------------------------------------------
// ������ ����
//------------------------------------------------------------------------------
function CreateThreadMain: Integer;
var
    hogino : Integer;
begin
    Result := 0;

    // ���� �迭 ũ�� ����
    SetLength(gThread,   gMaxDev + 1);
    SetLength(gMsgList,  gMaxDev + 1);
    SetLength(gCommLog,  gMaxDev + 1);
    SetLength(gIniInfo,  gMaxDev + 1);
    SetLength(gTabSheet, gMaxDev + 1);
    SetLength(gListBox,  gMaxDev + 1);

    // ������ ī���� ���� �ʱ�ȭ
    gThreadRemaining := 0;

    // ������ �ȿ��� �޽��� ��½� ���
    gThreadMsg := TStringList.Create;

    for hogino := 1 to gMaxDev do
    begin
        // INI ���ڿ� ��ü ����
        gIniInfo[hogino].IniCaption := TStringList.Create;
        gIniInfo[hogino].IniType := TStringList.Create;
        gIniInfo[hogino].IniSleep := TStringList.Create;
        gIniInfo[hogino].IniTimeOut := TStringList.Create;
        gIniInfo[hogino].IniCommValue := TStringList.Create;
        gIniInfo[hogino].IniStationQty := TStringList.Create;
        gIniInfo[hogino].IniForkQty  := TStringList.Create;
        gIniInfo[hogino].IniLogFile  := TStringList.Create;
        gIniInfo[hogino].IniDisplay  := TStringList.Create;
        gIniInfo[hogino].IniLanguege := TStringList.Create;

        // INI ���� �о����
        if ReadIniParameter(hogino) = False then break;;

        // TAB SHEET ���� ����
        gTabSheet[hogino] := TTabSheet.Create(fmMain.PageControl1);
        gTabSheet[hogino].PageControl := fmMain.PageControl1;
        gTabSheet[hogino].Name := 'Sheet' + IntToStr(hogino);
        gTabSheet[hogino].Caption := gIniInfo[hogino].IniCaption.Strings[0];

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
        gListBox[hogino].PopupMenu := fmMain.PopupMenu1;

        // ��� �α� ��ü ����
        gCommLog[hogino] := THmxLog.Create(gPath, Format('%s%3.3d', [COM_LOG_PREFIX, hogino]), 'Log', False, False);

        // �޽��� ����Ʈ ��ü ����
        gMsgList[hogino] := THmxMsgList.Create(gListBox[hogino], fmMain.CheckBox1, 100);

        if CreateThread(hogino) = False
        then begin
            ShowMessage('INI_TYPE Value Not Found.');
            break;
        end;
    end;

    // ��ü ������ ���� ���н�
    if gThreadRemaining < gMaxDev
    then Result := 1;
end;


//------------------------------------------------------------------------------
// ������ ���� �ϱ�
//------------------------------------------------------------------------------
function CreateThread(hogino : Integer) : Boolean;
begin
    Result := True;

    if hogino <= 0
    then begin
        Result := False;
        Exit;
    end;

    if gIniInfo[hogino].IniType.Strings[0] = INI_VAL_CONTROL
    then begin
        gThread[hogino] :=
                    THmxControl.Create(hogino,
                                              fmMain.Handle,
                                              U_WMG_CTL,
                                              gMyIni,
                                              INI_SEC_PREFIX + IntToStr(hogino),
                                              @shmptr^);

        gTabSheet[hogino].Caption := ' ' + INI_VAL_CONTROL;
    end
    else Result := False;

    if Result = True
    then begin
        gThread[hogino].Priority := tpLower;
        gThread[hogino].OnTerminate := fmMain.ThreadTerminate;                  // ������ ���� �̺�Ʈ ����
        gThread[hogino].Status := U_SYS_THR_ALIVE;                              // ������ ���� ����
        gThread[hogino].Restart := False;                                       // ������ ����� ����
        gThread[hogino].Resume;                                                 // �ʱ���� ������ ������忡�� ����Ƿη� ����
        Inc(gThreadRemaining);                                                  // ������ ���� ī���� ����
    end;
end;

//------------------------------------------------------------------------------
// INI Parameter �б�
//------------------------------------------------------------------------------
function ReadIniParameter(hogino : Integer) : Boolean;
begin
    Result := False;

    // CAPTION
    gIniInfo[hogino].IniCaption.Text := String(ReadIni(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_CAPTION, INI_CTL_FILE));
    if gIniInfo[hogino].IniCaption.Text = ''
    then begin
        ShowMessage('INI_CAPTION Not Found.');
        exit;
    end;

    // TYPE
    gIniInfo[hogino].IniType.Text := String(ReadIni(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_TYPE, INI_CTL_FILE));
    if gIniInfo[hogino].IniType.Text = ''
    then begin
        ShowMessage('INI_TYPE Not Found.');
        exit;
    end;

    // SLEEP
    gIniInfo[hogino].IniSleep.Text := String(ReadIni(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_SLEEP, INI_CTL_FILE));
    if gIniInfo[hogino].IniSleep.Text = ''
    then begin
        ShowMessage('INI_SLEEP Not Found.');
        exit;
    end;

    // TIMEOUT
    gIniInfo[hogino].IniTimeOut.Text := String(ReadIni(INI_SEC_PREFIX + IntToStr(hogino), INI_IDN_TIMEOUT, INI_CTL_FILE));
    if gIniInfo[hogino].IniTimeOut.Text = ''
    then begin
        ShowMessage('INI_TIMEOUT Not Found.');
        exit;
    end;

    // ',' �����ڸ� CR ��ȯ�Ͽ� �迭ȭ ó��
    gIniInfo[hogino].IniCommValue.Text := StringReplace(gIniInfo[hogino].IniCommValue.Text, ',', U_CTC_CR, [rfReplaceAll]);

    Result := True;
end;


//------------------------------------------------------------------------------
// ������ ������� �ʿ��� ��� Ÿ�̸ӿ��� �ش� �������� ���¸� Ȯ���ϰ�
// �����尡 ����� �ϱ����� ����� ��쿡�� �����带 �ٽ� �����Ѵ�.
//------------------------------------------------------------------------------
procedure WatchdogThread;
var
    hogino   : Integer;
    ExitCode : DWORD;
    rc       : Boolean;
begin
    // �׾��ִ� ������ ����ó��
    for hogino := 1 to gMaxDev do
    begin
        if gThread[hogino].Status = U_SYS_THR_KILL
        then Continue;

        rc := GetExitCodeThread(gThread[hogino].Handle, ExitCode);

        if (gThread[hogino].LoopCurrentCount = gThread[hogino].LoopBeforeCount) or
           (rc = False) or
           (ExitCode <> STILL_ACTIVE)
        then begin
            // ������ ��������
            SuspendThread(gThread[hogino].Handle);
            TerminateThread(gThread[hogino].Handle, 0);
            gThreadMsg.Add(IntToStr(hogino) + 'Force Terminate Successfuly!');

            Sleep(3000);

            // ������ �ٽ� ����
            if CreateThread(hogino) = True
            then gThreadMsg.Add(IntToStr(hogino) + 'CreateThread Successfuly!')
            else gThreadMsg.Add(IntToStr(hogino) + 'CreateThread Failed!');
        end;

        // ���� ���� ǥ��
        if (gThread[hogino].LoopCurrentCount <> gThread[hogino].LoopBeforeCount)
        then begin
            if Copy(gTabSheet[hogino].Caption, 1, 1) = '/'
            then gTabSheet[hogino].Caption := '-' + Copy(gTabSheet[hogino].Caption, 2, 100)
            else
            if Copy(gTabSheet[hogino].Caption, 1, 1) = '-'
            then gTabSheet[hogino].Caption := '\' + Copy(gTabSheet[hogino].Caption, 2, 100)
            else
            if Copy(gTabSheet[hogino].Caption, 1, 1) = '\'
            then gTabSheet[hogino].Caption := '|' + Copy(gTabSheet[hogino].Caption, 2, 100)
            else
            if Copy(gTabSheet[hogino].Caption, 1, 1) = '|'
            then gTabSheet[hogino].Caption := '/' + Copy(gTabSheet[hogino].Caption, 2, 100)
            else gTabSheet[hogino].Caption := '/' + Copy(gTabSheet[hogino].Caption, 1, 100);
        end
        else gThreadMsg.Add(IntToStr(hogino) + 'LoopCurrentCount and LoopBeforeCount is equal');

        gThread[hogino].LoopBeforeCount := gThread[hogino].LoopCurrentCount;
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
        gListBox[hogino].Free;
        gTabSheet[hogino].Free;

        gMsgList[hogino].Free;
        gCommLog[hogino].Free;

        gIniInfo[hogino].IniCaption.Free;
        gIniInfo[hogino].IniType.Free;
        gIniInfo[hogino].IniSleep.Free;
        gIniInfo[hogino].IniTimeOut.Free;
        gIniInfo[hogino].IniCommValue.Free;
        gIniInfo[hogino].IniStationQty.Free;
        gIniInfo[hogino].IniForkQty.Free;
        gIniInfo[hogino].IniLogFile.Free;
        gIniInfo[hogino].IniDisplay.Free;
        gIniInfo[hogino].IniLanguege.Free;
    end;

    gStartLog.Free;

    gThreadMsg.Free;

    // ���� �迭 �޸� ����
    gIniInfo := nil;
    gTabSheet := nil;
    gListBox := nil;
    gMsgList := nil;
    gCommLog := nil;
    gStartLog := nil;

    gDayOfChange.Free;
    gRemoveLogData.Free;

    // Ini ��ü ����
    gMyIni.Free;
end;

end.
