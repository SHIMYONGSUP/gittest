unit helco.serial.tcp.server.mode_14byte;

interface

uses
  Windows, Messages, SysUtils, Classes, StdCtrls, hmx.constant, hmx.define,
  HmxClass, HmxFunc, IdTCPClient, System.IniFiles, IdGlobal, cs_rtv;

type
  THelcoSerialTcpServerMode = class(THmxThread)
  private
    { Private declarations }
    FComSock  : TIdTCPClient;
    FWhsNo    : Integer;
    FRtvNo    : Integer;
    FGrpNo    : Integer;
    FResult   : Boolean;
    FSleep    : Integer;
    FRtvCount : Integer;
    FTimeOut  : Integer;
    FDisplay  : Boolean;
    FShmInfo  : ^RTV_INFO;
    FSection  : String;
    FSequence : Integer;

    FOrderSeq : Integer;

    function check_connect : Boolean;
    function try_connecting : Boolean;
    function request_status : Boolean;
    function read_message : Integer;

    procedure UpdateRtvStatus(rcvbuf : aMesgType);
    function byte_to_hexa(mesg:TIdBytes ; size:integer) : String;
    function byte_to_hexa2(mesg:aMesgType ; size:integer) : String;
    function SendOrder(strmesg : rMesgType) : Boolean;
    //----- Common Function --------------------------------------------------------
    function cs_check_bcc(buffer: String; len:integer) : byte;
    //function cs_check_crc(buffer: String; len:integer) : byte;

  protected
    procedure Execute; override;
  public
    constructor Create(Id : Integer; WHandle : HWND; WMessage : Integer;
                                            MyIni : TiniFile; Section : String; ShmInfo : Pointer);
  end;

implementation

uses MainForm;

var
    g_count : integer = 0;
    g_ord_no : integer = 0;

//------------------------------------------------------------------------------
// Thread Create
//------------------------------------------------------------------------------
constructor THelcoSerialTcpServerMode.Create(Id : Integer; WHandle : HWND; WMessage : Integer;
                                            MyIni : TiniFile; Section : String; ShmInfo : Pointer);
var
    CommValue : TStringList;
begin
    Inherited Create(True);
    FreeOnTerminate := True;

    Identifier := Id;
    LoopBeforeCount := 0;
    LoopCurrentCount := 0;
    FSequence := 0;
    WindowHandle := WHandle;
    WindowMessage := WMessage;

    FSection := Section;

    // Sleep �ð�
    FSleep := StrToIntDef(MyIni.ReadString(FSection, 'SLEEP', ''), 500);

    // TimeOut �ð�
    FTimeOut := StrToIntDef(MyIni.ReadString(FSection, 'TIMEOUT', ''), 1000);

    // WHS_NO
    FWhsNo := StrToIntDef(MyIni.ReadString(FSection, 'WHS_NO', ''), 0);

    // RTV_NO
    FRtvNo := StrToIntDef(MyIni.ReadString(FSection, 'RTV_NO', ''), 0);

    // GRP_NO
    FGrpNo := StrToIntDef(MyIni.ReadString(FSection, 'GRP_NO', ''), 0);

    // RTV COUNT
    FRtvCount := StrToIntDef(MyIni.ReadString(FSection, 'RTV_COUNT', ''), 1);

    // �ۼ��� ������ ȭ�� ǥ�� ���� (Y/N)
    FDisplay := (MyIni.ReadString(FSection, 'DISPLAY', '') = 'Y');

    CommValue := TStringList.Create;
    CommValue.Text := MyIni.ReadString(FSection, 'PARAMETER', '');
    CommValue.Text := StringReplace(CommValue.Text, ',', U_CTC_CR, [rfReplaceAll]);

    // ��� �������� �����Ѵ�.
    // ����, ������ ���� ������ �ƴϸ� ������ ����ϰ� �����Ѵ�.
    try
        try
            FComSock := TIdTCPClient.Create(nil);
            FComSock.Host := CommValue.Strings[0];
            FComSock.Port := StrToInt(CommValue.Strings[1]);
            //FComSock.ReadTimeout := StrToInt(CommValue.Strings[2]);
            //FComSock.ConnectTimeout := StrToInt(CommValue.Strings[2]);

        except
            on E: Exception do
            begin
                DisplayMessage(Format('%s(%d)', [E.Message, E.HelpContext]));
                FResult := False;
                Exit;
            end;
        end;
    finally
        CommValue.Free;
    end;

    // �����޸� ������ ���� ����
    FShmInfo := ShmInfo;

    FResult := True;

    DisplayMessage('Thread Create Success!');
end;

//------------------------------------------------------------------------------
//  ���� ����
//------------------------------------------------------------------------------
procedure THelcoSerialTcpServerMode.Execute;
var
    ord_no, rtv_pos : Integer;
    sendOrder_m, sendOrder_a : rMesgType;
begin
    while not Terminated do
  	begin
        LoopCurrentCount := (LoopCurrentCount + 1) and $FFFF;

        sleep(FSleep);

        // -------------------------------------------------------------
        // Port open
        // -------------------------------------------------------------
        if check_connect = False then Continue;

        // -------------------------------------------------------------
        // ���¹���
        // -------------------------------------------------------------
        if request_status = False
        then begin
            DisplayMessage('SEND > ���¹��� ����.');
            Continue;
        end;

        // -------------------------------------------------------------
        // ���� ���� OPERATION
        // -------------------------------------------------------------
        if read_message <> 0
        then begin
            DisplayMessage('read_message �̻� ');
            Continue;
        end;

        // RTV ������ �� �� ��� PEND�� ���� ��ȯ
        rtv_pos := 0;

        // -------------------------------------------------------------
        // RTV �������
        // -------------------------------------------------------------
        if (shmptr^.grp.rtvmaul[FRtvNo].status = U_COM_WAIT) or
           (shmptr^.grp.rtvmaul[FRtvNo].status = U_COM_PEND)
        then begin
            sendOrder_m[0] := shmptr^.grp.rtvmaul[FRtvNo].orderClass;
            sendOrder_m[1] := 0;
            sendOrder_m[2] := 0;

            if shmptr^.grp.rtvmaul[FRtvNo].orderClass = U_RTV_FNC_MOVE
            then begin
                rtv_pos := shmptr^.grp.rtvmaul[FRtvNo].fromStation;
            end;

            if shmptr^.grp.rtvmaul[FRtvNo].orderClass = U_RTV_FNC_LOAD
            then begin
                rtv_pos := shmptr^.grp.rtvmaul[FRtvNo].fromStation;
            end;

            if shmptr^.grp.rtvmaul[FRtvNo].orderClass = U_RTV_FNC_UNLD
            then begin
                rtv_pos := shmptr^.grp.rtvmaul[FRtvNo].toStation;
            end;

            if rtv_pos > 15
            then begin
                sendOrder_m[3] := $1111;
                sendOrder_m[4] := rtv_pos;
            end
            else begin
                sendOrder_m[3] := 0;
                sendOrder_m[4] := rtv_pos;
            end;

            if SendOrder(sendOrder_m) = True
            then begin
                shmptr^.grp.rtvmaul[FRtvNo].status := U_COM_NONE;
            end;

            sleep(500);

            // -------------------------------------------------------------
            // ���� ���� OPERATION
            // -------------------------------------------------------------
            if read_message <> 0
            then begin
                DisplayMessage('read_message �̻� ');
                Continue;
            end;
        end;

        for ord_no := 1 to U_MAX_WORK do
        begin
            // -------------------------------------------------------------
            // RTV �ڵ����
            // -------------------------------------------------------------
            // TEST
            shmptr^.grp.rtvwork[ord_no].orderClass := U_RTV_FNC_MOVE;
            shmptr^.grp.rtvwork[ord_no].fromStation := 6;
            shmptr^.grp.rtvwork[ord_no].status := U_COM_WAIT;
            shmptr^.grp.rtvwork[ord_no].rtvNo := 1;

            if (shmptr^.grp.rtvwork[ord_no].status = U_COM_WAIT) or
               (shmptr^.grp.rtvwork[ord_no].status = U_COM_PEND)
            then begin
                // ȣ�� Ȯ��
                if shmptr^.grp.rtvwork[ord_no].rtvNo <> FRtvNo
                then Continue;

                sendOrder_a[0] := shmptr^.grp.rtvwork[ord_no].orderClass;
                sendOrder_a[1] := 0;
                sendOrder_a[2] := 0;

                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_MOVE
                then begin
                    rtv_pos := shmptr^.grp.rtvwork[ord_no].fromStation;
                end;

                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_LOAD
                then begin
                    rtv_pos := shmptr^.grp.rtvwork[ord_no].fromStation;
                end;

                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_UNLD
                then begin
                    rtv_pos := shmptr^.grp.rtvwork[ord_no].toStation;
                end;

                if rtv_pos > 15
                then begin
                    sendOrder_a[3] := $1111;
                    sendOrder_a[4] := rtv_pos;
                end
                else begin
                    sendOrder_a[3] := 0;
                    sendOrder_a[4] := rtv_pos;
                end;

                if SendOrder(sendOrder_a) = True
                then begin
                    shmptr^.grp.rtvwork[ord_no].status := U_COM_PEND;
                    g_ord_no := ord_no;
                end;

                sleep(500);

                // -------------------------------------------------------------
                // ���� ���� OPERATION
                // -------------------------------------------------------------
                if read_message <> 0
                then begin
                    DisplayMessage('read_message �̻� ');
                    Continue;
                end;
            end;
        end;
    end;

    // ������ ����� ���� Disconnect & Free
    try
        try
            FComSock.Disconnect;
        except
        end;
    finally
        FComSock.Free;
    end;

    DisplayMessage('Thread Terminated....');
end;

//------------------------------------------------------------------------------
// ���� ���� ���� üũ / ���� �õ�
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.check_connect : Boolean;
var
    c_stat : Boolean;
begin
    c_stat := False;

    try
        c_stat := FComSock.Connected;
    except
        on E: Exception
        do DisplayMessage(Format('%s', [E.Message]));
    end;

    // ���� �ȵ� �����̸�
    if c_stat = False
    then c_stat := try_connecting;

    Result := c_stat;
end;

//------------------------------------------------------------------------------
// ���� ���� �õ�
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.try_connecting : Boolean;
var
    c_stat : Boolean;
begin                                 c_stat := False;

    try
        // Indy Socket ���� �õ�
        FComSock.Connect;

        c_stat := True;
    except
        on E: Exception
        do DisplayMessage(Format('%s', [E.Message]));
    end;

    Result := c_stat;
end;

//------------------------------------------------------------------------------
// ���¹���
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.request_status : Boolean;
var
    ck_sum : Integer;
    msgdat : String;
    rtv_no, seq_no, chk_sm  : String;
    id_byte : TIdBytes;
    retcod : Boolean;
begin
    retcod := False;

    // ���� ����
    try
        // int -> 16��������ȯ.
        msgdat := Format('%4.4x', [0]);                 // data

        // Check Sum ���
        ck_sum := cs_check_bcc(msgdat, length(msgdat));

        inc(FSequence);

        // Sequence ����
        if FSequence > 99
        then FSequence := 1;

        // int -> 16��������ȯ.
        rtv_no := Format('%2.2x', [Identifier]);        // rtv no
        seq_no := Format('%2.2x', [FSequence]);         // sequence no
        chk_sm := Format('%2.2x', [ck_sum]);            // check sum

        AppendByte(Id_byte, U_CTB_ENQ);
        AppendByte(Id_byte, U_CTB_ENQ_CMD);
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(rtv_no[1]), 2), 0));     // rtv no
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(rtv_no[2]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(seq_no[1]), 2), 0));     // sequence
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(seq_no[2]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[1]), 2), 0));     // data
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[2]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[3]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[4]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(chk_sm[1]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(chk_sm[2]), 2), 0));
        AppendByte(Id_byte, U_CTB_CR);
        AppendByte(Id_byte, U_CTB_LF);

        // Socket ���� ����. TIdBytes
        FComSock.Socket.Write(Id_byte);

        retcod := True;
    except
        DisplayMessage('SEND> Request Status send fail!');
        result := retcod;
        exit;
    end;
    DisplayMessage('SEND> ' + byte_to_hexa(id_byte, 14));

    result := retcod;
end;

//------------------------------------------------------------------------------
// ���� -> 16���� ���ڿ� (IdBytes)
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.byte_to_hexa(mesg:TIdBytes; size:integer) : String;
var
    strbuf : String;
    my_i : Integer;
begin
    strbuf := '';

    for my_i := 0 to size -1 do
        strbuf := strbuf + Format('%2.2x ', [mesg[my_i]]);

    Result := strbuf;
end;

//------------------------------------------------------------------------------
// ���� -> 16���� ���ڿ� (array of byte)
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.byte_to_hexa2(mesg:aMesgType; size:integer) : String;
var
    strbuf : String;
    my_i : Integer;
begin
    strbuf := '';

    for my_i := 1 to size  do
        strbuf := strbuf + Format('%2.2x ', [mesg[my_i]]);

    Result := strbuf;
end;

//------------------------------------------------------------------------------
procedure THelcoSerialTcpServerMode.UpdateRtvStatus(rcvbuf : aMesgType);
begin
    // ���� ��ġ
    shmptr^.grp.rtvinfo[FRtvNo].currentPosition     := cs_rtv_position(rcvbuf);
    // �ڵ� ����
    shmptr^.grp.rtvinfo[FRtvNo].operationMode       := cs_rtv_mode(rcvbuf);
    // ������� - ����
    //shmptr^.whs[FWhsNo].rtvinf[FGrpNo][FRtvNo].emergency         := cs_rtv_mode(rcvbuf);
    // ���� ����
    shmptr^.grp.rtvinfo[FRtvNo].error               := cs_rtv_error(rcvbuf);
    // �����ڵ�
    shmptr^.grp.rtvinfo[FRtvNo].errorCode           := cs_rtv_error_code(rcvbuf);
    // ���꿡���ڵ�
    shmptr^.grp.rtvinfo[FRtvNo].errorSubCode        := cs_rtv_sub_error_code(rcvbuf);
    // ���� �ӵ�
    shmptr^.grp.rtvinfo[FRtvNo].speed               := cs_rtv_speed(rcvbuf);
    // ȭ������
    shmptr^.grp.rtvinfo[FRtvNo].exists[U_RTV_BED_1] := cs_rtv_loaded1(rcvbuf);
    // Ÿ�ӿ���
    shmptr^.grp.rtvinfo[FRtvNo].timeOver            := cs_rtv_time_over(rcvbuf);
    // ���� (0:����, 1:���, 2:���簡��(ȭ�� ��), 3:�̻�, 5:����)
    shmptr^.grp.rtvinfo[FRtvNo].status              := cs_rtv_status(rcvbuf);
end;

//------------------------------------------------------------------------------
// �޼��� ����
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.read_message : Integer;
var
    retcod, my_i,seqnum, size : Integer;
    rcvbuf : aMesgType;
begin
    retcod := 99;

    size := FComSock.IOHandler.InputBuffer.Size;
    if size > 0
    then begin
        try
            repeat
                // RTV������ �� 14�ڸ��� ����.
                for my_i := 1 to size do
                    rcvbuf[my_i] := FComSock.Socket.ReadByte;

                DisplayMessage('RECV> ' + byte_to_hexa2(rcvbuf, size));

                // ���� ������ ���� üũ �̻�.
                if (rcvbuf[1]  <> U_CTB_ACK) or
                   (rcvbuf[14] <> U_CTB_LF) or
                   (rcvbuf[13] <> U_CTB_CR)
                then begin
                    retcod := 1;
                    break;
                end;

                // Message�� ���¹��ǿ� ���� ������ ���.
                if rcvbuf[2] = U_CTB_ENQ_ACK
                then begin
                    // Rtv���� ������Ʈ.
                    UpdateRtvStatus(rcvbuf);

                    DisplayMessage('RECV> ' + byte_to_hexa2(rcvbuf, 14));
                end
                // Order�� ���� ����.
                else
                if rcvbuf[2] =  U_CTB_ORD_ARK
                then begin
                    // ���信 ���� Sequence ��ȣ�� �����´�.
                    seqnum := StrToIntDef('$' + Char(rcvbuf[5]) + char(rcvbuf[6]), 0);

                    // ��� ���� Sequnce ��ȣ�� ���� Sequnce��ȣ�� ���ٸ� ���� �Ϸ� ó��. (�ڵ� ��� �� ��츸)
                    if shmptr^.grp.rtvwork[g_ord_no].status = U_COM_PEND
                    then begin
                        if FOrderSeq = seqnum
                        then shmptr^.grp.rtvwork[g_ord_no].status := U_COM_COMT
                        else shmptr^.grp.rtvwork[g_ord_no].status := U_COM_PEND;
                    end;

                    DisplayMessage('RECV Order> ' + byte_to_hexa2(rcvbuf, 14));
                end;

                // ����ð� ����.
                shmptr^.grp.rtvwork[g_ord_no].ackTime := Now;

                retcod := 0;
            until (False);
        except on E: Exception do
            begin
                if retcod <> 0
                then retcod := 2;
                DisplayMessage('RECV> ' + byte_to_hexa2(rcvbuf, 14));
            end;

        end;
    end
    else
        retcod := 0;

    Result := retcod;
end;

//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.SendOrder(strmesg : rMesgType) : Boolean;
var
    ck_sum : Integer;
    msgdat  : String;
    rtv_no, seq_no, chk_sm  : String;
    id_byte : TIdBytes;
    retcod : Boolean;
    strbuf : array[0..4] of Integer;
begin
    retcod := False;

    // ���� ����
    try
        // msgdat 0���� ä��
        msgdat := StringOfChar('0', 30);

        // �̵� ��ɽ� ???
        if strbuf[0] = U_RTV_FNC_MOVE
        then strbuf[1]:= strbuf[1] + $0100;

        // HOME, �ڵ���ȯ, ����, STOP/START �� ��츸 �ش�
        case strmesg[0] of
            U_RTV_FNC_HOME : strbuf[1] := $1000;
            U_RTV_FNC_ONLI : strbuf[1] := $2000;
            U_RTV_FNC_RSET : strbuf[1] := $4000;
            U_RTV_FNC_STOP : strbuf[1] := $0000; //  ������  start bit ��  + ������..  $8000 �ƴϰ� $0000��.
        end;

        // MOVE �� ��� PASS C/V ����ֱ�
        case strmesg[0] of
            U_RTV_FNC_MOVE : strmesg[2] := $0001;
        end;

        // Check Sum ���
        ck_sum := cs_check_bcc(msgdat, length(msgdat));

        inc(FSequence);

        // Sequence ����
        if FSequence > 99
        then FSequence := 1;

        // int -> 16��������ȯ.
        rtv_no := Format('%2.2x', [Identifier]);        // rtv no
        seq_no := Format('%2.2x', [FSequence]);         // sequence no
        chk_sm := Format('%2.2x', [ck_sum]);            // check sum
        msgdat :=  Format('%x%x%x%x', [strmesg[1], strmesg[2], strmesg[3], strmesg[4]]);

        AppendByte(Id_byte, U_CTB_ENQ);
        AppendByte(Id_byte, U_CTB_ORD_CMD);
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(rtv_no[1]), 2), 0));     // rtv no
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(rtv_no[2]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(seq_no[1]), 2), 0));     // sequence
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(seq_no[2]), 2), 0));

        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[1]), 2), 0));     // rtv FROM 1
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[2]), 2), 0));     // rtv TO 1
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[3]), 2), 0));     // rtv no
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(msgdat[4]), 2), 0));     // rtv no

        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(chk_sm[1]), 2), 0));
        AppendByte(Id_byte, StrToIntDef('$' + IntToHex(Ord(chk_sm[2]), 2), 0));
        AppendByte(Id_byte, U_CTB_CR);
        AppendByte(Id_byte, U_CTB_LF);

        // Socket ���� ����. TIdBytes
        FComSock.Socket.Write(Id_byte);

        // �۾����� ������ ��ȣ ����.
        FOrderSeq := FSequence;

        retcod := True;
    except
        DisplayMessage('ORDR> Send order Fail!');
        result := retcod;
        exit;
    end;

    DisplayMessage('ORDR> ' + byte_to_hexa(id_byte, 14));

    result := retcod;
end;

//----- Common Function --------------------------------------------------------
function THelcoSerialTcpServerMode.cs_check_bcc(buffer: String; len: integer): byte;
var
    bcc    : integer;
    my_i   : integer;
begin
    bcc := 0;
    for my_i := 1 to len do
    begin
        bcc := bcc + ord(buffer[my_i]);
        bcc := bcc AND $FF;
    end;

    result := bcc;
end;

end.
