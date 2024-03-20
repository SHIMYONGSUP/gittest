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

    // Sleep 시간
    FSleep := StrToIntDef(MyIni.ReadString(FSection, 'SLEEP', ''), 500);

    // TimeOut 시간
    FTimeOut := StrToIntDef(MyIni.ReadString(FSection, 'TIMEOUT', ''), 1000);

    // WHS_NO
    FWhsNo := StrToIntDef(MyIni.ReadString(FSection, 'WHS_NO', ''), 0);

    // RTV_NO
    FRtvNo := StrToIntDef(MyIni.ReadString(FSection, 'RTV_NO', ''), 0);

    // GRP_NO
    FGrpNo := StrToIntDef(MyIni.ReadString(FSection, 'GRP_NO', ''), 0);

    // RTV COUNT
    FRtvCount := StrToIntDef(MyIni.ReadString(FSection, 'RTV_COUNT', ''), 1);

    // 송수신 데이터 화면 표시 유무 (Y/N)
    FDisplay := (MyIni.ReadString(FSection, 'DISPLAY', '') = 'Y');

    CommValue := TStringList.Create;
    CommValue.Text := MyIni.ReadString(FSection, 'PARAMETER', '');
    CommValue.Text := StringReplace(CommValue.Text, ',', U_CTC_CR, [rfReplaceAll]);

    // 통신 설정값을 적용한다.
    // 만약, 가져온 값이 정상이 아니면 설정을 취소하고 종료한다.
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

    // 공유메모리 포인터 변수 설정
    FShmInfo := ShmInfo;

    FResult := True;

    DisplayMessage('Thread Create Success!');
end;

//------------------------------------------------------------------------------
//  메인 실행
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
        // 상태문의
        // -------------------------------------------------------------
        if request_status = False
        then begin
            DisplayMessage('SEND > 상태문의 실패.');
            Continue;
        end;

        // -------------------------------------------------------------
        // 전문 수신 OPERATION
        // -------------------------------------------------------------
        if read_message <> 0
        then begin
            DisplayMessage('read_message 이상 ');
            Continue;
        end;

        // RTV 응답이 안 온 경우 PEND로 상태 전환
        rtv_pos := 0;

        // -------------------------------------------------------------
        // RTV 수동명령
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
            // 전문 수신 OPERATION
            // -------------------------------------------------------------
            if read_message <> 0
            then begin
                DisplayMessage('read_message 이상 ');
                Continue;
            end;
        end;

        for ord_no := 1 to U_MAX_WORK do
        begin
            // -------------------------------------------------------------
            // RTV 자동명령
            // -------------------------------------------------------------
            // TEST
            shmptr^.grp.rtvwork[ord_no].orderClass := U_RTV_FNC_MOVE;
            shmptr^.grp.rtvwork[ord_no].fromStation := 6;
            shmptr^.grp.rtvwork[ord_no].status := U_COM_WAIT;
            shmptr^.grp.rtvwork[ord_no].rtvNo := 1;

            if (shmptr^.grp.rtvwork[ord_no].status = U_COM_WAIT) or
               (shmptr^.grp.rtvwork[ord_no].status = U_COM_PEND)
            then begin
                // 호기 확인
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
                // 전문 수신 OPERATION
                // -------------------------------------------------------------
                if read_message <> 0
                then begin
                    DisplayMessage('read_message 이상 ');
                    Continue;
                end;
            end;
        end;
    end;

    // 쓰레드 종료시 소켓 Disconnect & Free
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
// 소켓 접속 상태 체크 / 접속 시도
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

    // 접속 안된 상태이면
    if c_stat = False
    then c_stat := try_connecting;

    Result := c_stat;
end;

//------------------------------------------------------------------------------
// 소켓 접속 시도
//------------------------------------------------------------------------------
function THelcoSerialTcpServerMode.try_connecting : Boolean;
var
    c_stat : Boolean;
begin                                 c_stat := False;

    try
        // Indy Socket 접속 시도
        FComSock.Connect;

        c_stat := True;
    except
        on E: Exception
        do DisplayMessage(Format('%s', [E.Message]));
    end;

    Result := c_stat;
end;

//------------------------------------------------------------------------------
// 상태문의
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

    // 전문 전송
    try
        // int -> 16진수형변환.
        msgdat := Format('%4.4x', [0]);                 // data

        // Check Sum 계산
        ck_sum := cs_check_bcc(msgdat, length(msgdat));

        inc(FSequence);

        // Sequence 생성
        if FSequence > 99
        then FSequence := 1;

        // int -> 16진수형변환.
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

        // Socket 전문 전송. TIdBytes
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
// 정수 -> 16진수 문자열 (IdBytes)
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
// 정수 -> 16진수 문자열 (array of byte)
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
    // 현재 위치
    shmptr^.grp.rtvinfo[FRtvNo].currentPosition     := cs_rtv_position(rcvbuf);
    // 자동 수동
    shmptr^.grp.rtvinfo[FRtvNo].operationMode       := cs_rtv_mode(rcvbuf);
    // 비상정지 - 없음
    //shmptr^.whs[FWhsNo].rtvinf[FGrpNo][FRtvNo].emergency         := cs_rtv_mode(rcvbuf);
    // 에러 유무
    shmptr^.grp.rtvinfo[FRtvNo].error               := cs_rtv_error(rcvbuf);
    // 에러코드
    shmptr^.grp.rtvinfo[FRtvNo].errorCode           := cs_rtv_error_code(rcvbuf);
    // 서브에러코드
    shmptr^.grp.rtvinfo[FRtvNo].errorSubCode        := cs_rtv_sub_error_code(rcvbuf);
    // 주행 속도
    shmptr^.grp.rtvinfo[FRtvNo].speed               := cs_rtv_speed(rcvbuf);
    // 화물감지
    shmptr^.grp.rtvinfo[FRtvNo].exists[U_RTV_BED_1] := cs_rtv_loaded1(rcvbuf);
    // 타임오버
    shmptr^.grp.rtvinfo[FRtvNo].timeOver            := cs_rtv_time_over(rcvbuf);
    // 상태 (0:작중, 1:대기, 2:이재가능(화물 유), 3:이상, 5:수동)
    shmptr^.grp.rtvinfo[FRtvNo].status              := cs_rtv_status(rcvbuf);
end;

//------------------------------------------------------------------------------
// 메세지 수신
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
                // RTV전문은 총 14자리로 구성.
                for my_i := 1 to size do
                    rcvbuf[my_i] := FComSock.Socket.ReadByte;

                DisplayMessage('RECV> ' + byte_to_hexa2(rcvbuf, size));

                // 전문 마지막 문자 체크 이상.
                if (rcvbuf[1]  <> U_CTB_ACK) or
                   (rcvbuf[14] <> U_CTB_LF) or
                   (rcvbuf[13] <> U_CTB_CR)
                then begin
                    retcod := 1;
                    break;
                end;

                // Message가 상태문의에 대한 응답일 경우.
                if rcvbuf[2] = U_CTB_ENQ_ACK
                then begin
                    // Rtv상태 업데이트.
                    UpdateRtvStatus(rcvbuf);

                    DisplayMessage('RECV> ' + byte_to_hexa2(rcvbuf, 14));
                end
                // Order에 대한 응답.
                else
                if rcvbuf[2] =  U_CTB_ORD_ARK
                then begin
                    // 응답에 대한 Sequence 번호를 가져온다.
                    seqnum := StrToIntDef('$' + Char(rcvbuf[5]) + char(rcvbuf[6]), 0);

                    // 명령 전송 Sequnce 번호와 응답 Sequnce번호가 같다면 전송 완료 처리. (자동 명령 일 경우만)
                    if shmptr^.grp.rtvwork[g_ord_no].status = U_COM_PEND
                    then begin
                        if FOrderSeq = seqnum
                        then shmptr^.grp.rtvwork[g_ord_no].status := U_COM_COMT
                        else shmptr^.grp.rtvwork[g_ord_no].status := U_COM_PEND;
                    end;

                    DisplayMessage('RECV Order> ' + byte_to_hexa2(rcvbuf, 14));
                end;

                // 응답시간 저장.
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

    // 전문 전송
    try
        // msgdat 0으로 채움
        msgdat := StringOfChar('0', 30);

        // 이동 명령시 ???
        if strbuf[0] = U_RTV_FNC_MOVE
        then strbuf[1]:= strbuf[1] + $0100;

        // HOME, 자동전환, 리셋, STOP/START 인 경우만 해당
        case strmesg[0] of
            U_RTV_FNC_HOME : strbuf[1] := $1000;
            U_RTV_FNC_ONLI : strbuf[1] := $2000;
            U_RTV_FNC_RSET : strbuf[1] := $4000;
            U_RTV_FNC_STOP : strbuf[1] := $0000; //  다음에  start bit 가  + 됨으로..  $8000 아니고 $0000임.
        end;

        // MOVE 일 경우 PASS C/V 살려주기
        case strmesg[0] of
            U_RTV_FNC_MOVE : strmesg[2] := $0001;
        end;

        // Check Sum 계산
        ck_sum := cs_check_bcc(msgdat, length(msgdat));

        inc(FSequence);

        // Sequence 생성
        if FSequence > 99
        then FSequence := 1;

        // int -> 16진수형변환.
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

        // Socket 전문 전송. TIdBytes
        FComSock.Socket.Write(Id_byte);

        // 작업지시 시퀀스 번호 저장.
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
