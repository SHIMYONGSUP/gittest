unit cs_mode;

interface

uses
    SysUtils, HmxFunc, hmx.constant, hmx.define, JSON, StrUtils;

    procedure UcsLogMeg(ASeparate, Msg: String);

implementation

//------------------------------------------------------------------------------
// LOG �޼��� ���
//------------------------------------------------------------------------------
procedure UcsLogMeg(ASeparate, Msg: String);
var
    buffer : String;
    fp : TextFile;
begin
    try
        buffer := 'C:\UcsLog' + '\' + FormatDateTime('YYYY-MM-DD', Now);

        if not DirectoryExists(buffer)
        then ForceDirectories(buffer);  // ���� ����

        buffer := buffer + '\' + ASeparate + '.Log';

        if FileExists(buffer)
        then begin
            AssignFile(fp, buffer);
            Append(fp);
        end
        else begin
            AssignFile(fp, buffer);
            ReWrite(fp);
        end;

        buffer := FormatDateTime('YYYY/MM/DD HH:MM:SS', Now) + '> ' +  Msg;

        WriteLn(fp, buffer);
    finally
        CloseFile(fp);
    end;
end;

//------------------------------------------------------------------------------
// hyb 20211108 SHM ����� : CEP : ȣ���ϴ� �� ����.
//------------------------------------------------------------------------------
{procedure cs_shm_dev_set_json(AText: String);// �׽�Ʈ �� JSonString ���� �޾ƿͺ���.  JSonObject);
var
    AJSONObject: TJSONObject;
    SetValue: Integer;
    AWhsNo, PlcNo, RtvNo, ZonNo, StcNo, WrkNo: Integer;
    ADevStr: String;
    AJSONValue: TJSONValue;
begin

    ADevStr := '';

    AJSONObject := TJSONObject.ParseJSONValue(AText) as TJSONObject;

    try
        AWhsNo := TJSONNumber(AJSONObject.Get('WhsNo').JsonValue).AsInt;

        // â�� �����
        ADevStr := 'Whs' + Format('%2.2d',[AWhsNo]);
        AJSONValue := AJSONObject.FindValue(ADevStr);

        if Assigned(AJSONValue) // key �� ��ã���� nil
        then begin
            SetValue := TJSONNumber(AJSONValue).AsInt;
            shmptr^.whs[AWhsNo].enable := 0 <> SetValue;
        end;

        // PLC NO
        for PlcNo := 1 to U_MAX_PLC do
        begin
            // â��PLC �����                                                     // ycu20211124 PLC�����
            ADevStr := 'WhsPlc' + Format('%.2d%.2d',[AWhsNo, U_MAX_PLC]);
            AJSONValue := AJSONObject.FindValue(ADevStr);

            if Assigned(AJSONValue) // key �� ��ã���� nil
            then begin
                SetValue := TJSONNumber(AJSONValue).AsInt;
                shmptr^.whs[AWhsNo].plc[U_MAX_PLC].oprmod := 0 <> SetValue;
                //shmptr^.whs[AWhsNo].plc[U_MAX_PLC].oprmod := 0 <> SetValue;
            end;
        end;

        // RTV For Loop
        for RtvNo := 1 to U_MAX_RTV do
        begin
            ADevStr := 'RTV' + Format('%2.2d%2.2d',[AWhsNo, RtvNo]);
            AJSONValue := AJSONObject.FindValue(ADevStr);

            if Assigned(AJSONValue) // key �� ��ã���� nil
            then begin
                SetValue := TJSONNumber(AJSONValue).AsInt;
                //shmptr^.whs[AWhsNo].rtv[RtvNo].enable := 0 <> SetValue;
            end;
        end;

        // S/C MODE
        for StcNo := 1 to U_MAX_STC do
        begin
            ADevStr := 'STC' + Format('%2.2d%2.2d',[AWhsNo, StcNo]);
            AJSONValue := AJSONObject.FindValue(ADevStr);
            // STC
            if Assigned(AJSONValue)
            then begin
                SetValue := TJSONNumber(AJSONValue).AsInt;
                //shmptr^.whs[AWhsNo].stc[StcNo].enable := 0 <> SetValue;

                for WrkNo := 1 to  U_MAX_STC_STN do
                begin

                    ADevStr := 'STCWRK' + Format('%2.2d%2.2d%2.2d',[AWhsNo, StcNo, WrkNo]);
                    AJSONValue := AJSONObject.FindValue(ADevStr);
                    // STC WORK
                    if Assigned(AJSONValue)
                    then begin
                        SetValue := TJSONNumber(AJSONValue).AsInt;
                        //shmptr^.whs[AWhsNo].stc[StcNo].work[WrkNo].enable := 0 <> SetValue;
                    end;
                end;
            end;
        end;

    finally
        AJSONObject.Free;
    end;
end;
}
//------------------------------------------------------------------------------
// hyb 20221106 CNV SEMI ORDER
{
    PLC_WORK �� JSON SERIALIZE �Ͽ� �����´�.
    �ش� JSON STRING �� PARSING �Ͽ� SEMI PLC_WORK �� �Է��Ѵ�.
}
//------------------------------------------------------------------------------
{procedure cs_shm_dev_cnv_order_json(AText: string);
var
    LJSONValue: TJSONValue;
    LSemiPlcWork: ^PLC_WORK;
    LWhsNo: Integer;
    LStnNo, LSerial, LToStn: Integer;
begin
    LWhsNo  := 1;

    LJSONValue := TJSONObject.ParseJSONValue(AText);

    try
        // ���� ��ã���� OUT.
        if not LJSONValue.TryGetValue<integer>('sttnid', LStnNo)
        then Exit;

        if not LJSONValue.TryGetValue<integer>('serial', LSerial)
        then Exit;

        if not LJSONValue.TryGetValue<integer>('tosttn', LToStn)
        then Exit;

        LSemiPlcWork := @(shmptr^.whs[LWhsNo].semi[LStnNo]);

        LSemiPlcWork.sttnid := LStnNo;
        LSemiPlcWork.serial := LSerial;
        LSemiPlcWork.tosttn := LToStn;
        LSemiPlcWork.settim := Now();

        LSemiPlcWork.status := U_COM_WAIT;
    finally
        LJSONValue.Free;
    end;
end;
}
end.
