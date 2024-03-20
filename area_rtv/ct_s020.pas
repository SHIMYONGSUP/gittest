unit ct_s020;

interface

type
    possibleRtv = TArray<string>;

procedure syncro_rtv_control(grp_no : Integer);
function rtv_can_work(rtv_no: Integer): boolean;
function get_reserve_rtv(rtv_no: Integer): Integer;
function get_working_no : Integer;
function check_not_comflict(rtv_no, allocate_rtv_no: Integer): boolean;
procedure rtv_move(grp_no, rtv_no, allocate_rtv_no : Integer);
function get_first_work(grp_no : Integer; ts_min : TDatetime) : Integer;
procedure check_rtv_avoid(grp_no: Integer);
procedure set_rtv_work(grp_no : Integer);
function check_max_point(loading_p, unloading_p, current_p: Integer): Integer;
function check_min_point(loading_p, unloading_p, current_p: Integer): Integer;
procedure set_pass_count(workNo : Integer);
procedure update_work_status_wait;
function station_to_possible(group_no, station_no: Integer): possibleRtv;

var
    g_pass_cnt : Integer;

implementation

uses SysUtils, Windows, GlobalVar, System.JSON,
     MainForm, GlobalFnc, hmx.constant, hmx.define, cs_rtv;

//------------------------------------------------------------------------------
procedure syncro_rtv_control(grp_no : Integer);
begin
    // RTV 회피 기동 확인
    check_rtv_avoid(grp_no);

    // FRST -> RESV 작업 상태 변경
    set_rtv_work(grp_no);

    // RESV -> WAIT 작업 상태 변경
    update_work_status_wait;

end;

// -----------------------------------------------------------------------------
function rtv_can_work(rtv_no: integer): boolean;
var
    workNo : Integer;
begin
    Result := False;

    // 사용 설정 확인
    // 고장으로 사용하지 않는(한쪽에 밀어둔) RTV는 enable 로 판단한다.
    if shmptr^.grp.rtvinfo[rtv_no].enable = false
    then Exit;

    // RTV 작업모드 확인
    if shmptr^.grp.rtvinfo[rtv_no].operationMode = false
    then Exit;

    // RTV 에러 여부 확인
    if shmptr^.grp.rtvinfo[rtv_no].error = true
    then Exit;

    // RTV가 대기 상태가 아닌 경우 (1. 대기, 2. 작중)
    if shmptr^.grp.rtvinfo[rtv_no].status <> U_RTV_STAT_REDY
    then Exit;

    // 작업 할당 중인지 확인
    for workNo := 1 to U_MAX_WORK do
    begin
        if shmptr^.grp.rtvwork[workNo].rtvNo = rtv_no
        then Exit;
    end;

    // 이동 할당 중인지 확인
    for workNo := 1 to U_MAX_MOVE do
    begin
        if shmptr^.grp.rtvmove[workNo].status <> U_COM_NONE
        then Exit;
    end;

    // 수동 할당 중인지 확인
    for workNo := 1 to U_MAX_MANL do
    begin
        if shmptr^.grp.rtvmaul[workNo].status <> U_COM_NONE
        then Exit;
    end;


    Result := True;
end;

// -----------------------------------------------------------------------------
function get_reserve_rtv(rtv_no: integer): Integer;
var
    work_no : Integer;
begin
    Result := 0;

    // WORK NO 확인
    for work_no := 1 to U_MAX_WORK do
    begin
        // RESV 할당된 RTV 번호 확인
        if shmptr^.grp.rtvwork[work_no].status = U_COM_RESV
        then begin
            if shmptr^.grp.rtvwork[work_no].rtvNo = rtv_no
            then Continue;

            Result := shmptr^.grp.rtvwork[work_no].rtvNo;
        end;
    end;
end;

// -----------------------------------------------------------------------------
function get_working_no : Integer;
var
    work_no : Integer;
begin
    Result := 0;

    // OTHER RTV NO 확인
    for work_no := 1 to U_MAX_WORK do
    begin
        // OTHER RTV 작업 유무 확인
        if shmptr^.grp.rtvwork[work_no].status = U_COM_NONE
        then Continue;

        if shmptr^.grp.rtvwork[work_no].status = U_COM_FRST
        then Continue;

        Result := work_no;
        Exit;
    end;
end;

// -----------------------------------------------------------------------------
function check_not_comflict(rtv_no, allocate_rtv_no : integer): boolean;
var
    i : Integer;
    loading_p, unloading_p, other_current_p, current_p, max_p, min_p : Integer;
    comflict : Boolean;
begin
    comflict := False;

    for i := 1 to U_MAX_WORK do
    begin
        // 할당 된 RTV의 작업 가져오기
        if shmptr^.grp.rtvwork[i].rtvNo = allocate_rtv_no
        then begin
            // Check Load Point, Unloading Point, Current Point
            loading_p := station_to_position(1, shmptr^.grp.rtvwork[i].fromStation);
            unloading_p := station_to_position(1, shmptr^.grp.rtvwork[i].toStation);
            other_current_p := station_to_position(1, shmptr^.grp.rtvinfo[allocate_rtv_no].currentPosition);

            current_p := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition);

            // 만약 Loading이 끝난 경우 From Station을 Current Position으로 설정
            if shmptr^.grp.rtvinfo[rtv_no].exists[1] = True
            then loading_p := station_to_position(1, shmptr^.grp.rtvinfo[allocate_rtv_no].currentPosition);

            // 3 Point 중 가장 큰 수, 작은 수로 범위 판별
            max_p := check_max_point(loading_p, unloading_p, other_current_p);
            min_p := check_min_point(loading_p, unloading_p, other_current_p);

            // RTV 와 OTHER RTV MAX, MIN 값 비교
            if (current_p > max_p) or
               (current_p < min_p)
            then begin
                // 작업범위 밖이면
                comflict := False;
            end
            else begin
                // 작업범위 안이면
                comflict := True;
            end;
        end;
    end;

    Result := comflict;
end;

// -----------------------------------------------------------------------------
procedure rtv_move(grp_no, rtv_no, allocate_rtv_no : integer);
var
    workNo, my_i, my_j : Integer;
    loading_p, unloading_p, current_p, loading_p_allocate, unloading_p_allocate,
    current_p_allocate, max_p_allocate, min_p_allocate, max_p_work, min_p_work : Integer;
    myRtvInfo : RTV_INFO;
    myRtvWork : RTV_WORK;
    ord_date : TDateTime;
begin
    ord_date := 0;

    // Get Allocation RTV Work No
    for workNo := 1 to U_MAX_WORK do
    begin
        if shmptr^.grp.rtvwork[workNo].rtvNo = allocate_rtv_no
        then begin
            myRtvWork := shmptr^.grp.rtvwork[workNo];
            myRtvInfo := shmptr^.grp.rtvInfo[allocate_rtv_no];
        end;
    end;

    // Allocation RTV Check Load Point, Unloading Point, Current Point
    loading_p_allocate   := station_to_position(grp_no, myRtvWork.fromStation);
    unloading_p_allocate := station_to_position(grp_no, myRtvWork.toStation);
    current_p_allocate   := station_to_position(grp_no, myRtvInfo.currentPosition);

    // 만약 Loading이 끝난 경우 From Station을 Current Position으로 설정
    if myRtvInfo.exists[1] = True
    then loading_p_allocate := station_to_position(1, myRtvInfo.currentPosition);

    // 3 Point 중 가장 큰 수, 작은 수로 범위 판별
    max_p_allocate := check_max_point(loading_p_allocate, unloading_p_allocate, current_p_allocate);
    min_p_allocate := check_min_point(loading_p_allocate, unloading_p_allocate, current_p_allocate);

    // 영역 밖의 반송 명령이 있으면 반송 명령 부여
    // 영역 밖의 반송 명령이 없으면 단순 이동명령 부여
    for my_i := 1 to U_MAX_WORK do
    begin
        workNo := get_first_work(grp_no, ord_date);
        ord_date := shmptr^.grp.rtvwork[workNo].setTime;

        if workNo = 0
        then Break;

        loading_p   := station_to_position(grp_no, shmptr^.grp.rtvwork[workNo].fromStation);
        unloading_p := station_to_position(grp_no, shmptr^.grp.rtvwork[workNo].toStation);
        current_p   := station_to_position(grp_no, shmptr^.grp.rtvinfo[rtv_no].currentPosition);

        max_p_work := check_max_point(loading_p, unloading_p, current_p);
        min_p_work := check_min_point(loading_p, unloading_p, current_p);

        // 할당 된 작업 영역 보다 포지션이 큰 쪽에 작업영역 체크 후 지시
        if ((max_p_allocate < max_p_work) and
            (max_p_allocate < min_p_work)) and
            (current_p_allocate < current_p)
        then begin
            shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
            shmptr^.grp.rtvwork[workNo].status := U_COM_WAIT;

            // 할당된 작업 바로 수행
            for my_j := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[my_j].rtvNo = allocate_rtv_no
                then begin
                    shmptr^.grp.rtvwork[my_j].status := U_COM_WAIT;
                end;
            end;

            Exit;
        end;

        // 할당 된 작업 영역 보다 포지션이 작은 쪽에 작업영역 체크 후 지시
        if ((min_p_allocate > max_p_work) and
            (min_p_allocate > max_p_work)) and
            (current_p_allocate > current_p)
        then begin
            shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
            shmptr^.grp.rtvwork[workNo].status := U_COM_WAIT;

            // 할당된 작업 바로 수행
            for my_j := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[my_j].rtvNo = allocate_rtv_no
                then begin
                    shmptr^.grp.rtvwork[my_j].status := U_COM_WAIT;
                end;
            end;


            Exit;
        end;
    end;

    // 할당 된 작업영역 외에 받을 명령이 없어서 단순 이동 지시
    shmptr^.grp.rtvmove[rtv_no].rtvNo := rtv_no;
    shmptr^.grp.rtvmove[rtv_no].orderClass := U_RTV_FNC_MOVE;

    // Allocation RTV의 현재 위치와 반대로 이동 필요
    if (station_to_position(1, shmptr^.grp.rtvInfo[allocate_rtv_no].currentPosition) >
       station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition))
    then shmptr^.grp.rtvmove[rtv_no].toStation := position_to_station(grp_no, min_p_allocate - gPosRange)
    else shmptr^.grp.rtvmove[rtv_no].toStation := position_to_station(grp_no, max_p_allocate + gPosRange);

    shmptr^.grp.rtvmove[rtv_no].status := U_COM_WAIT;

    // 할당된 작업 바로 수행
    for my_j := 1 to U_MAX_WORK do
    begin
        if shmptr^.grp.rtvwork[my_j].rtvNo = allocate_rtv_no
        then begin
            shmptr^.grp.rtvwork[my_j].status := U_COM_WAIT;
        end;
    end;
end;

// -----------------------------------------------------------------------------
procedure check_rtv_avoid(grp_no: Integer);
var
    rtv_no, allocate_rtv_no : Integer;
begin
    // RTV가 OTHER RTV 작업 범위에 있어서 피해 줘야 하는 지 체크 하는 부분
    for rtv_no := 1 to U_MAX_RTV do
    begin
        // RTV가 명령을 받을 수 있는 상황이면
        if rtv_can_work(rtv_no) = True
        then begin
            // RESERVE WORK 확인
            allocate_rtv_no := get_reserve_rtv(rtv_no);

            if allocate_rtv_no <> 0
            then begin
                // OTHER RTV 작업과 충돌 확인, 자기자신이 나오면 OUT
                if rtv_no = allocate_rtv_no
                then Continue;

                // OTHER RTV 작업과 충돌 시
                // 범위 밖 명령 있는지 확인
                if check_not_comflict(rtv_no, allocate_rtv_no) = True
                then begin
                    // 범위 밖 명령이 없으니 이동 지시
                    rtv_move(grp_no, rtv_no, allocate_rtv_no);
                end
            end
        end;
    end;
end;

// -----------------------------------------------------------------------------
procedure set_rtv_work(grp_no : integer);
var
    other_workNo, loading_p, unloading_p, current_p, max_p_allocate, rtv_no,
    min_p_allocate, my_i, my_j, my_k, workNo, max_p_work, min_p_work, from_station, to_station,
    from_allocation, to_allocation , rtv_no_allocation, position_allocation : Integer;
    check_from_possible : boolean;
    ord_date : TDateTime;
    from_rtv_possible, to_rtv_possible : TArray<string>;
begin
    ord_date := 0;

    // FRST -> RESV (최초 할당)
    for my_i := 1 to U_MAX_WORK do
    begin
        rtv_no := 0;
        workNo := get_first_work(grp_no, ord_date);
        ord_date := shmptr^.grp.rtvwork[workNo].setTime;

        if workNo = 0
        then Break;

        // 가져온 WORK의 FROM, TO로 Possible 호기를 들고 온다.
        from_station := shmptr^.grp.rtvwork[workNo].fromStation;
        to_station := shmptr^.grp.rtvwork[workNo].toStation;

        from_rtv_possible := station_to_possible(grp_no, from_station);
        to_rtv_possible := station_to_possible(grp_no, to_station);

        for my_j := 1 to U_MAX_RTV do
        begin
            if StrToIntDef(to_rtv_possible[my_j], 0) = 0 then Continue;

            if rtv_can_work(StrToInt(to_rtv_possible[my_j])) = true
            then begin
                check_from_possible := false;

                for my_k := 1 to U_MAX_RTV do
                begin
                    // to_possible에서 선정 된 호기가 from_possible에 없는 경우
                    if to_rtv_possible[my_j] = from_rtv_possible[my_k]
                    then begin
                        check_from_possible := true;
                        break;
                    end;
                end;

                if check_from_possible = false then Continue;

                rtv_no := StrToInt(to_rtv_possible[my_j]);
                Break;
            end;
        end;

        // RTV POSSIBLE 못 가져 온 경우 아래 진행 하지 않도록
        if rtv_no = 0
        then Continue;

        // 처음 할당 된 호기가 받을 수 있는 상태이면 다른 RTV 작업범위 확인 후 RESV로 상태 변경
        // 다른 RTV 작업범위 확인
        other_workNo := get_working_no;

        if other_workNo <> 0
        then begin
            // Allocate ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
            // Allocate RTV 작업과 location
            from_allocation := station_to_position(1, shmptr^.grp.rtvwork[other_workNo].fromStation);
            to_allocation := station_to_position(1, shmptr^.grp.rtvwork[other_workNo].toStation);
            rtv_no_allocation := shmptr^.grp.rtvwork[other_workNo].rtvNo;
            position_allocation := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no_allocation].currentPosition);

            // 만약 Loading이 끝난 경우 From Station을 Current Position으로 설정
            if shmptr^.grp.rtvinfo[rtv_no_allocation].exists[1] = True
            then from_allocation := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no_allocation].currentPosition);

            // 3 Point 중 가장 큰 수, 작은 수로 범위 판별
            max_p_allocate := check_max_point(from_allocation, to_allocation, position_allocation);
            min_p_allocate := check_min_point(from_allocation, to_allocation, position_allocation);

            // Schedule ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
            loading_p   := station_to_position(1, shmptr^.grp.rtvwork[workNo].fromStation);
            unloading_p := station_to_position(1, shmptr^.grp.rtvwork[workNo].toStation);
            current_p   := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition);

            max_p_work := check_max_point(loading_p, unloading_p, current_p);
            min_p_work := check_min_point(loading_p, unloading_p, current_p);

            if (max_p_allocate < max_p_work) and
               (max_p_allocate < min_p_work)
            then begin
                shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
                shmptr^.grp.rtvwork[workNo].status := U_COM_RESV;

                set_pass_count(workNo);

                Continue;
            end;

            if (min_p_allocate > max_p_work) and
               (min_p_allocate > min_p_work)
            then begin
                shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
                shmptr^.grp.rtvwork[workNo].status := U_COM_RESV;

                set_pass_count(workNo);

                Continue;
            end;

            // 다른 호기에 passCount 가 5 이상이면 빠져 나간다.
            if shmptr^.grp.rtvwork[workNo].passCount > gPassCount
            then Exit;
        end
        else begin
            shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
            shmptr^.grp.rtvwork[workNo].status := U_COM_RESV;

            set_pass_count(workNo);
        end;
    end;
end;

// -----------------------------------------------------------------------------
function check_max_point(loading_p, unloading_p, current_p: Integer): Integer;
var
    max_p : Integer;
begin
    if loading_p - unloading_p > 0
    then begin
       if loading_p - current_p > 0
       then max_p := loading_p
       else max_p := current_p
    end
    else
    begin
        if unloading_p - current_p > 0
        then max_p := unloading_p
        else max_p := current_p
    end;

    Result := max_p;
end;

// -----------------------------------------------------------------------------
function check_min_point(loading_p, unloading_p, current_p: Integer): Integer;
var
    min_p : Integer;
begin
    if loading_p - unloading_p < 0
    then begin
       if loading_p - current_p < 0
       then min_p := loading_p
       else min_p := current_p
    end
    else
    begin
        if unloading_p - current_p < 0
        then min_p := unloading_p
        else min_p := current_p
    end;

    Result := min_p;
end;

//------------------------------------------------------------------------------
function get_first_work(grp_no : Integer; ts_min : TDatetime) : Integer;
var
    workNo, sel_idx   : Integer;
    ts_comp, ts_max : TDateTime;
begin
    sel_idx  := 0;
    ts_max   := now;
    ts_comp  := now;

    for workNo := 1 to U_MAX_WORK do
    begin
        // start_time(Now or 재탐색 기준 ord_no) 보다 늦은 시간의 예약 작업 확인
        if (shmptr^.grp.rtvwork[workNo].status = U_COM_FRST) and
           (shmptr^.grp.rtvwork[workNo].setTime > ts_min)    and
           (shmptr^.grp.rtvwork[workNo].setTime < ts_max)
        then begin
            // 조건에 부합하는 예약작업에 대해 setTime으로 비교하여 Return
            if sel_idx = 0
            then begin
                sel_idx := workNo;
                ts_comp := shmptr^.grp.rtvwork[workNo].setTime;
            end
            else begin
                if shmptr^.grp.rtvwork[workNo].setTime < ts_comp
                then begin
                    sel_idx := workNo;
                    ts_comp := shmptr^.grp.rtvwork[workNo].setTime;
                end;
            end;
        end;
    end;

    Result := sel_idx;
end;

// -----------------------------------------------------------------------------
procedure set_pass_count(workNo : Integer);
var
    other_workNo : Integer;
begin
    for other_workNo := 1 to U_MAX_WORK do
    begin
        // start_time(Now or 재탐색 기준 ord_no) 보다 늦은 시간의 예약 작업 확인
        if (shmptr^.grp.rtvwork[workNo].setTime >
           shmptr^.grp.rtvwork[other_workNo].setTime) and
           (shmptr^.grp.rtvwork[other_workNo].status = U_COM_FRST)
        then begin
            shmptr^.grp.rtvwork[other_workNo].passCount :=
                                shmptr^.grp.rtvwork[other_workNo].passCount + 1;
        end;
    end;
end;

// -----------------------------------------------------------------------------
procedure update_work_status_wait;
var
    workNo, loading_p, unloading_p, current_p, other_rtv, max_p_work,
    min_p_work, rtv_no : Integer;
    keep_resv : Boolean;
begin
    for workNo := 1 to U_MAX_WORK do
    begin
        keep_resv := False;

        if shmptr^.grp.rtvwork[workNo].status <> U_COM_RESV
        then Continue;

        rtv_no := shmptr^.grp.rtvwork[workNo].rtvNo;

        // 기준 RTV
        loading_p   := station_to_position(1, shmptr^.grp.rtvwork[workNo].fromStation);
        unloading_p := station_to_position(1, shmptr^.grp.rtvwork[workNo].toStation);
        current_p   := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition);

        max_p_work := check_max_point(loading_p, unloading_p, current_p);
        min_p_work := check_min_point(loading_p, unloading_p, current_p);

        for other_rtv := 1 to U_MAX_RTV do
        begin
            if rtv_no = other_rtv
            then Continue;

            // Allocation RTV
            current_p   := station_to_position(1, shmptr^.grp.rtvinfo[other_rtv].currentPosition);

            // Allocation RTV랑 받아야 할 작업이 곂치는 경우 명령 할당 안하고 유지
            if (max_p_work >= current_p) and
               (min_p_work <= current_p)
            then keep_resv := True;
        end;

        if keep_resv = True
        then Continue;

        shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
        shmptr^.grp.rtvwork[workNo].status := U_COM_WAIT;
    end;
end;

// -----------------------------------------------------------------------------
function station_to_possible(group_no, station_no: Integer): possibleRtv;
var
    my_i : Integer;
    possibleStr: TArray<string>;
begin
    for my_i := 1 to gSetMaxSttn[group_no] do
    begin
        if gSttnInfo[group_no][my_i].station_no <> station_no
        then Continue;

        // split 하여 배열에 할당.
        possibleStr := gSttnInfo[group_no][my_i].possible.Split(['#']);

        Break;
    end;

    Result := possibleStr;
end;

end.

