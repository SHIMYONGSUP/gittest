unit cs_rtv;

interface

uses SysUtils, Windows, GlobalVar, System.JSON,
     MainForm, hmx.constant, hmx.define;

function station_to_position(group_no, station_no: Integer): Integer;
function position_to_station(group_no, position_no: integer): Integer;
function cs_rtv_mode(rcvbuf : aMesgType) : Boolean;            // RTV ���� �Ǵ�
function cs_rtv_loaded1(rcvbuf : aMesgType): Boolean;          // FD#1 ȭ�� ����
function cs_rtv_position(rcvbuf : aMesgType) : Integer;        // RTV ����ġ
function cs_rtv_speed(rcvbuf : aMesgType) : Integer;           // RTV �̵� �ӵ�
function cs_rtv_error(rcvbuf : aMesgType): Boolean;            // RTV ���� �Ǵ�
function cs_rtv_error_code(rcvbuf : aMesgType): Integer;       // RTV ���� �ڵ�
function cs_rtv_sub_error_code(rcvbuf : aMesgType): Integer;   // ���� ���� �ڵ�
function cs_rtv_time_over(rcvbuf : aMesgType): Boolean;        // RTV Ÿ�ӿ���
function cs_rtv_status(rcvbuf : aMesgType) : Integer;          // RTV ����
function cs_rtv_ready_status(rcvbuf : aMesgType) : Boolean;    // RTV ��ɴ��
function cs_rtv_wrk_no(rcvbuf : aMesgType; rtv_no: Integer): Integer;
function byte_to_ascii(mesg:array of Byte ; sidx, size:integer) : String;

implementation

// -----------------------------------------------------------------------------
function station_to_position(group_no, station_no: Integer): Integer;
var
    my_i, postion_no : Integer;
begin
    postion_no := 0 ;
    for my_i := 1 to gSetMaxSttn[group_no] do
    begin
        if gSttnInfo[group_no][my_i].station_no <> station_no
        then Continue;

        postion_no := gSttnInfo[group_no][my_i].position;

        Break;
    end;

    Result := postion_no;
end;

// -----------------------------------------------------------------------------
function position_to_station(group_no, position_no: integer): Integer;
var
    my_i, station_no : Integer;
begin
    station_no := 0;
    for my_i := 1 to gSetMaxSttn[group_no] do
    begin
        if gSttnInfo[group_no][my_i].position <> position_no
        then Continue;

        station_no := gSttnInfo[group_no][my_i].station_no;

        Break;
    end;

    Result := station_no;
end;

// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// ��ġ
//------------------------------------------------------------------------------
function cs_rtv_position(rcvbuf : aMesgType) : Integer;
var
    pos: Integer;
begin
    //pos := StrToIntDef('$'+byte_to_ascii(rcvbuf, 7, 4), 0) and $007F;
    pos := StrToIntDef('$'+byte_to_ascii(rcvbuf, 9, 2), 0) and $007F;
    Result  := pos;
end;

//------------------------------------------------------------------------------
// �ڵ� ����
//------------------------------------------------------------------------------
function cs_rtv_mode(rcvbuf : aMesgType) : Boolean;
var
    mode: Integer;
begin
    mode := rcvbuf[7] and $0002;
    result := (mode > 0);
end;

//------------------------------------------------------------------------------
// �̵� �ӵ�
//------------------------------------------------------------------------------
function cs_rtv_speed(rcvbuf : aMesgType) : Integer;
var
    speed: Integer;
begin
    // CE - 2 BED ��� �ʿ�
    speed := rcvbuf[8] and $0001;
    Result := speed;
end;

//------------------------------------------------------------------------------
// FD 1 ���� ����
//------------------------------------------------------------------------------
function cs_rtv_loaded1(rcvbuf : aMesgType): Boolean;
var
    load : Integer;
begin
    load := rcvbuf[8] and $0004;
    Result := (load > 0);
end;

//------------------------------------------------------------------------------
// FD 2 ���� ����
//------------------------------------------------------------------------------
function cs_rtv_loaded2(rcvbuf : aMesgType): Boolean;
var
    load : Integer;
begin
    load := rcvbuf[8] and $0008;
    Result := (load > 0);
end;

//------------------------------------------------------------------------------
// ��� ����
//------------------------------------------------------------------------------
function cs_rtv_ready_no_loaded(rcvbuf : aMesgType): boolean;
begin
    if (cs_rtv_mode(rcvbuf)) and                // RTV �ڵ�
       not cs_rtv_error(rcvbuf) and             // RTV ����
       not cs_rtv_loaded1(rcvbuf) and            // RTV ȭ����
       cs_rtv_ready_status(rcvbuf) and          // RTV ��� ---------------------- ��� ���� ���� ������ ����
      (cs_rtv_speed(rcvbuf) = 0)                // RTV ��������
    then result := True
    else result := False;
end;

//------------------------------------------------------------------------------
// ���� ���� ���� (ȭ�� ��)
//------------------------------------------------------------------------------
function cs_rtv_ready_with_loaded(rcvbuf : aMesgType): boolean;
begin
    if (cs_rtv_mode(rcvbuf)) and            // RTV �ڵ�
       not cs_rtv_error(rcvbuf) and         // RTV ����
       cs_rtv_loaded1(rcvbuf) and           // RTV ȭ����
       cs_rtv_ready_status(rcvbuf) and      // RTV ��� ---------------------- ��� ���� ���� ������ ����
      (cs_rtv_speed(rcvbuf) = 0)            // RTV ��������
    then result := True
    else result := False;
end;

//------------------------------------------------------------------------------
// Ÿ�� ����
//------------------------------------------------------------------------------
function cs_rtv_time_over(rcvbuf : aMesgType): Boolean;
var
    over : Integer;
begin
    over := rcvbuf[7] and $0001;
    result := (over > 0);
end;

//------------------------------------------------------------------------------
// ���� ����
//------------------------------------------------------------------------------
function cs_rtv_error(rcvbuf : aMesgType): Boolean;
var
    error : Integer;
begin
    error := rcvbuf[9] and $0008;
    Result := (error > 0);
end;

//------------------------------------------------------------------------------
// ���� �ڵ�
//------------------------------------------------------------------------------
function cs_rtv_error_code(rcvbuf : aMesgType): Integer;
var
    code, eror : Integer;
begin
    eror := rcvbuf[9] and $0008;
    if eror > 0
    then begin
        code := rcvbuf[8] and $000F;
    end
    else code := 0;

    Result := code;
end;

//------------------------------------------------------------------------------
// ���� ���� �ڵ�
//------------------------------------------------------------------------------
function cs_rtv_sub_error_code(rcvbuf : aMesgType): Integer;
var
    code: Integer;
begin
    code := rcvbuf[7] and $000F;
    Result := code;
end;

//------------------------------------------------------------------------------
// RTV ����  (0:����, 1:���, 2:���簡��(ȭ�� ��), 3:�̻�, 5:����)  ���,�̻��� �ƴϸ� �۾�ó����.
//------------------------------------------------------------------------------
function cs_rtv_status(rcvbuf : aMesgType) : Integer;
var
    status : Integer;
begin
    status := 0;

    // RTV ��� (����)
    if (cs_rtv_mode(rcvbuf) = false)
    then status := 5
    // RTV ��������
    else if cs_rtv_error(rcvbuf)
    then status := 3
    // RTV ���
    else if cs_rtv_ready_no_loaded(rcvbuf)
    then status := 1
    // RTV ȭ�� ���� (���� ��� ��� ����)
    else if cs_rtv_ready_with_loaded(rcvbuf)
    then status := 2;

    Result := status;
end;


//------------------------------------------------------------------------------
// RTV ���°� �����¸� True �ƴϸ� False
//------------------------------------------------------------------------------
function cs_rtv_ready_status(rcvbuf : aMesgType) : Boolean;
var
    over : Integer;
begin
    over := rcvbuf[7] and $0008;
    result := (over > 0);
end;

//------------------------------------------------------------------------------
// RTV �۾��� ���� �۾���ȣ ��ȯ�ϱ�
//------------------------------------------------------------------------------
function cs_rtv_wrk_no(rcvbuf : aMesgType; rtv_no: Integer): Integer;
var
    my_i : Integer;
    rvt_work_no: Integer;
begin
    for my_i := 1 to U_MAX_WORK do
    begin
        if shmptr^.grp.rtvwork[my_i].rtvNo = rtv_no
        then begin
            rvt_work_no := shmptr^.grp.rtvwork[my_i].workNo;
        end
        else begin
            rvt_work_no := 0;
        end;
    end;

    Result := rvt_work_no;
end;

//------------------------------------------------------------------------------s
function byte_to_ascii(mesg:array of Byte ; sidx, size:integer) : String;
var
    strbuf : String;
    i : Integer;
begin
    strbuf := '';
    for i := sidx to (sidx + size - 1) do
    begin
        strbuf := strbuf + char(StrToInt('$'+ IntToHex(Ord(mesg[i]),2) ));
    end;
    Result := strbuf;
end;


end.
