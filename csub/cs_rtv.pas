unit cs_rtv;

interface

uses SysUtils, Windows, GlobalVar, System.JSON,
     MainForm, hmx.constant, hmx.define;

function station_to_position(group_no, station_no: Integer): Integer;
function position_to_station(group_no, position_no: integer): Integer;
function cs_rtv_mode(rcvbuf : aMesgType) : Boolean;            // RTV 상태 판단
function cs_rtv_loaded1(rcvbuf : aMesgType): Boolean;          // FD#1 화물 유무
function cs_rtv_position(rcvbuf : aMesgType) : Integer;        // RTV 현위치
function cs_rtv_speed(rcvbuf : aMesgType) : Integer;           // RTV 이동 속도
function cs_rtv_error(rcvbuf : aMesgType): Boolean;            // RTV 에러 판단
function cs_rtv_error_code(rcvbuf : aMesgType): Integer;       // RTV 에러 코드
function cs_rtv_sub_error_code(rcvbuf : aMesgType): Integer;   // 서브 에러 코드
function cs_rtv_time_over(rcvbuf : aMesgType): Boolean;        // RTV 타임오버
function cs_rtv_status(rcvbuf : aMesgType) : Integer;          // RTV 상태
function cs_rtv_ready_status(rcvbuf : aMesgType) : Boolean;    // RTV 명령대기
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
// 위치
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
// 자동 여부
//------------------------------------------------------------------------------
function cs_rtv_mode(rcvbuf : aMesgType) : Boolean;
var
    mode: Integer;
begin
    mode := rcvbuf[7] and $0002;
    result := (mode > 0);
end;

//------------------------------------------------------------------------------
// 이동 속도
//------------------------------------------------------------------------------
function cs_rtv_speed(rcvbuf : aMesgType) : Integer;
var
    speed: Integer;
begin
    // CE - 2 BED 고려 필요
    speed := rcvbuf[8] and $0001;
    Result := speed;
end;

//------------------------------------------------------------------------------
// FD 1 적재 여부
//------------------------------------------------------------------------------
function cs_rtv_loaded1(rcvbuf : aMesgType): Boolean;
var
    load : Integer;
begin
    load := rcvbuf[8] and $0004;
    Result := (load > 0);
end;

//------------------------------------------------------------------------------
// FD 2 적재 여부
//------------------------------------------------------------------------------
function cs_rtv_loaded2(rcvbuf : aMesgType): Boolean;
var
    load : Integer;
begin
    load := rcvbuf[8] and $0008;
    Result := (load > 0);
end;

//------------------------------------------------------------------------------
// 대기 상태
//------------------------------------------------------------------------------
function cs_rtv_ready_no_loaded(rcvbuf : aMesgType): boolean;
begin
    if (cs_rtv_mode(rcvbuf)) and                // RTV 자동
       not cs_rtv_error(rcvbuf) and             // RTV 정상
       not cs_rtv_loaded1(rcvbuf) and            // RTV 화물무
       cs_rtv_ready_status(rcvbuf) and          // RTV 대기 ---------------------- 대기 상태 관련 데이터 없음
      (cs_rtv_speed(rcvbuf) = 0)                // RTV 정지상태
    then result := True
    else result := False;
end;

//------------------------------------------------------------------------------
// 이재 가능 상태 (화물 유)
//------------------------------------------------------------------------------
function cs_rtv_ready_with_loaded(rcvbuf : aMesgType): boolean;
begin
    if (cs_rtv_mode(rcvbuf)) and            // RTV 자동
       not cs_rtv_error(rcvbuf) and         // RTV 정상
       cs_rtv_loaded1(rcvbuf) and           // RTV 화물유
       cs_rtv_ready_status(rcvbuf) and      // RTV 대기 ---------------------- 대기 상태 관련 데이터 없음
      (cs_rtv_speed(rcvbuf) = 0)            // RTV 정지상태
    then result := True
    else result := False;
end;

//------------------------------------------------------------------------------
// 타임 오버
//------------------------------------------------------------------------------
function cs_rtv_time_over(rcvbuf : aMesgType): Boolean;
var
    over : Integer;
begin
    over := rcvbuf[7] and $0001;
    result := (over > 0);
end;

//------------------------------------------------------------------------------
// 에러 여부
//------------------------------------------------------------------------------
function cs_rtv_error(rcvbuf : aMesgType): Boolean;
var
    error : Integer;
begin
    error := rcvbuf[9] and $0008;
    Result := (error > 0);
end;

//------------------------------------------------------------------------------
// 에러 코드
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
// 서브 에러 코드
//------------------------------------------------------------------------------
function cs_rtv_sub_error_code(rcvbuf : aMesgType): Integer;
var
    code: Integer;
begin
    code := rcvbuf[7] and $000F;
    Result := code;
end;

//------------------------------------------------------------------------------
// RTV 상태  (0:작중, 1:대기, 2:이재가능(화물 유), 3:이상, 5:수동)  대기,이상이 아니면 작업처리함.
//------------------------------------------------------------------------------
function cs_rtv_status(rcvbuf : aMesgType) : Integer;
var
    status : Integer;
begin
    status := 0;

    // RTV 모드 (수동)
    if (cs_rtv_mode(rcvbuf) = false)
    then status := 5
    // RTV 에러상태
    else if cs_rtv_error(rcvbuf)
    then status := 3
    // RTV 대기
    else if cs_rtv_ready_no_loaded(rcvbuf)
    then status := 1
    // RTV 화물 감지 (이재 명령 대기 상태)
    else if cs_rtv_ready_with_loaded(rcvbuf)
    then status := 2;

    Result := status;
end;


//------------------------------------------------------------------------------
// RTV 상태가 대기상태면 True 아니면 False
//------------------------------------------------------------------------------
function cs_rtv_ready_status(rcvbuf : aMesgType) : Boolean;
var
    over : Integer;
begin
    over := rcvbuf[7] and $0008;
    result := (over > 0);
end;

//------------------------------------------------------------------------------
// RTV 작업이 가진 작업번호 반환하기
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
