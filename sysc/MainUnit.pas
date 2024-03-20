unit MainUnit;

interface

uses
  Windows, SysUtils, Classes, Dialogs, ExtCtrls, StdCtrls, Controls, Graphics, ComCtrls, IniFiles;

function CreateSHM: Integer;
function GetSttnInfo: Integer;

implementation

uses hmx.constant, hmx.define, MainForm, HmxFunc, cs_misc, GlobalVar;

//------------------------------------------------------------------------------
// �����޸� ����
//------------------------------------------------------------------------------
function CreateSHM: Integer;
begin
    Result := 0;

    // �����޸� ���� �õ�
    if GetSharedMemory(True) = False
    then begin
        // �����޸� ���� ���н� ���� �õ�
        if CreateSharedMemory(True) = False
        then Result := 1;
    end;
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


end.
