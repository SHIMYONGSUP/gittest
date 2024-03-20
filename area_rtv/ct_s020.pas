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
    // RTV ȸ�� �⵿ Ȯ��
    check_rtv_avoid(grp_no);

    // FRST -> RESV �۾� ���� ����
    set_rtv_work(grp_no);

    // RESV -> WAIT �۾� ���� ����
    update_work_status_wait;

end;

// -----------------------------------------------------------------------------
function rtv_can_work(rtv_no: integer): boolean;
var
    workNo : Integer;
begin
    Result := False;

    // ��� ���� Ȯ��
    // �������� ������� �ʴ�(���ʿ� �о��) RTV�� enable �� �Ǵ��Ѵ�.
    if shmptr^.grp.rtvinfo[rtv_no].enable = false
    then Exit;

    // RTV �۾���� Ȯ��
    if shmptr^.grp.rtvinfo[rtv_no].operationMode = false
    then Exit;

    // RTV ���� ���� Ȯ��
    if shmptr^.grp.rtvinfo[rtv_no].error = true
    then Exit;

    // RTV�� ��� ���°� �ƴ� ��� (1. ���, 2. ����)
    if shmptr^.grp.rtvinfo[rtv_no].status <> U_RTV_STAT_REDY
    then Exit;

    // �۾� �Ҵ� ������ Ȯ��
    for workNo := 1 to U_MAX_WORK do
    begin
        if shmptr^.grp.rtvwork[workNo].rtvNo = rtv_no
        then Exit;
    end;

    // �̵� �Ҵ� ������ Ȯ��
    for workNo := 1 to U_MAX_MOVE do
    begin
        if shmptr^.grp.rtvmove[workNo].status <> U_COM_NONE
        then Exit;
    end;

    // ���� �Ҵ� ������ Ȯ��
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

    // WORK NO Ȯ��
    for work_no := 1 to U_MAX_WORK do
    begin
        // RESV �Ҵ�� RTV ��ȣ Ȯ��
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

    // OTHER RTV NO Ȯ��
    for work_no := 1 to U_MAX_WORK do
    begin
        // OTHER RTV �۾� ���� Ȯ��
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
        // �Ҵ� �� RTV�� �۾� ��������
        if shmptr^.grp.rtvwork[i].rtvNo = allocate_rtv_no
        then begin
            // Check Load Point, Unloading Point, Current Point
            loading_p := station_to_position(1, shmptr^.grp.rtvwork[i].fromStation);
            unloading_p := station_to_position(1, shmptr^.grp.rtvwork[i].toStation);
            other_current_p := station_to_position(1, shmptr^.grp.rtvinfo[allocate_rtv_no].currentPosition);

            current_p := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition);

            // ���� Loading�� ���� ��� From Station�� Current Position���� ����
            if shmptr^.grp.rtvinfo[rtv_no].exists[1] = True
            then loading_p := station_to_position(1, shmptr^.grp.rtvinfo[allocate_rtv_no].currentPosition);

            // 3 Point �� ���� ū ��, ���� ���� ���� �Ǻ�
            max_p := check_max_point(loading_p, unloading_p, other_current_p);
            min_p := check_min_point(loading_p, unloading_p, other_current_p);

            // RTV �� OTHER RTV MAX, MIN �� ��
            if (current_p > max_p) or
               (current_p < min_p)
            then begin
                // �۾����� ���̸�
                comflict := False;
            end
            else begin
                // �۾����� ���̸�
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

    // ���� Loading�� ���� ��� From Station�� Current Position���� ����
    if myRtvInfo.exists[1] = True
    then loading_p_allocate := station_to_position(1, myRtvInfo.currentPosition);

    // 3 Point �� ���� ū ��, ���� ���� ���� �Ǻ�
    max_p_allocate := check_max_point(loading_p_allocate, unloading_p_allocate, current_p_allocate);
    min_p_allocate := check_min_point(loading_p_allocate, unloading_p_allocate, current_p_allocate);

    // ���� ���� �ݼ� ����� ������ �ݼ� ��� �ο�
    // ���� ���� �ݼ� ����� ������ �ܼ� �̵���� �ο�
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

        // �Ҵ� �� �۾� ���� ���� �������� ū �ʿ� �۾����� üũ �� ����
        if ((max_p_allocate < max_p_work) and
            (max_p_allocate < min_p_work)) and
            (current_p_allocate < current_p)
        then begin
            shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
            shmptr^.grp.rtvwork[workNo].status := U_COM_WAIT;

            // �Ҵ�� �۾� �ٷ� ����
            for my_j := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[my_j].rtvNo = allocate_rtv_no
                then begin
                    shmptr^.grp.rtvwork[my_j].status := U_COM_WAIT;
                end;
            end;

            Exit;
        end;

        // �Ҵ� �� �۾� ���� ���� �������� ���� �ʿ� �۾����� üũ �� ����
        if ((min_p_allocate > max_p_work) and
            (min_p_allocate > max_p_work)) and
            (current_p_allocate > current_p)
        then begin
            shmptr^.grp.rtvwork[workNo].rtvNo := rtv_no;
            shmptr^.grp.rtvwork[workNo].status := U_COM_WAIT;

            // �Ҵ�� �۾� �ٷ� ����
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

    // �Ҵ� �� �۾����� �ܿ� ���� ����� ��� �ܼ� �̵� ����
    shmptr^.grp.rtvmove[rtv_no].rtvNo := rtv_no;
    shmptr^.grp.rtvmove[rtv_no].orderClass := U_RTV_FNC_MOVE;

    // Allocation RTV�� ���� ��ġ�� �ݴ�� �̵� �ʿ�
    if (station_to_position(1, shmptr^.grp.rtvInfo[allocate_rtv_no].currentPosition) >
       station_to_position(1, shmptr^.grp.rtvinfo[rtv_no].currentPosition))
    then shmptr^.grp.rtvmove[rtv_no].toStation := position_to_station(grp_no, min_p_allocate - gPosRange)
    else shmptr^.grp.rtvmove[rtv_no].toStation := position_to_station(grp_no, max_p_allocate + gPosRange);

    shmptr^.grp.rtvmove[rtv_no].status := U_COM_WAIT;

    // �Ҵ�� �۾� �ٷ� ����
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
    // RTV�� OTHER RTV �۾� ������ �־ ���� ��� �ϴ� �� üũ �ϴ� �κ�
    for rtv_no := 1 to U_MAX_RTV do
    begin
        // RTV�� ����� ���� �� �ִ� ��Ȳ�̸�
        if rtv_can_work(rtv_no) = True
        then begin
            // RESERVE WORK Ȯ��
            allocate_rtv_no := get_reserve_rtv(rtv_no);

            if allocate_rtv_no <> 0
            then begin
                // OTHER RTV �۾��� �浹 Ȯ��, �ڱ��ڽ��� ������ OUT
                if rtv_no = allocate_rtv_no
                then Continue;

                // OTHER RTV �۾��� �浹 ��
                // ���� �� ��� �ִ��� Ȯ��
                if check_not_comflict(rtv_no, allocate_rtv_no) = True
                then begin
                    // ���� �� ����� ������ �̵� ����
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

    // FRST -> RESV (���� �Ҵ�)
    for my_i := 1 to U_MAX_WORK do
    begin
        rtv_no := 0;
        workNo := get_first_work(grp_no, ord_date);
        ord_date := shmptr^.grp.rtvwork[workNo].setTime;

        if workNo = 0
        then Break;

        // ������ WORK�� FROM, TO�� Possible ȣ�⸦ ��� �´�.
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
                    // to_possible���� ���� �� ȣ�Ⱑ from_possible�� ���� ���
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

        // RTV POSSIBLE �� ���� �� ��� �Ʒ� ���� ���� �ʵ���
        if rtv_no = 0
        then Continue;

        // ó�� �Ҵ� �� ȣ�Ⱑ ���� �� �ִ� �����̸� �ٸ� RTV �۾����� Ȯ�� �� RESV�� ���� ����
        // �ٸ� RTV �۾����� Ȯ��
        other_workNo := get_working_no;

        if other_workNo <> 0
        then begin
            // Allocate ���������������������������������������������������������
            // Allocate RTV �۾��� location
            from_allocation := station_to_position(1, shmptr^.grp.rtvwork[other_workNo].fromStation);
            to_allocation := station_to_position(1, shmptr^.grp.rtvwork[other_workNo].toStation);
            rtv_no_allocation := shmptr^.grp.rtvwork[other_workNo].rtvNo;
            position_allocation := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no_allocation].currentPosition);

            // ���� Loading�� ���� ��� From Station�� Current Position���� ����
            if shmptr^.grp.rtvinfo[rtv_no_allocation].exists[1] = True
            then from_allocation := station_to_position(1, shmptr^.grp.rtvinfo[rtv_no_allocation].currentPosition);

            // 3 Point �� ���� ū ��, ���� ���� ���� �Ǻ�
            max_p_allocate := check_max_point(from_allocation, to_allocation, position_allocation);
            min_p_allocate := check_min_point(from_allocation, to_allocation, position_allocation);

            // Schedule ���������������������������������������������������������
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

            // �ٸ� ȣ�⿡ passCount �� 5 �̻��̸� ���� ������.
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
        // start_time(Now or ��Ž�� ���� ord_no) ���� ���� �ð��� ���� �۾� Ȯ��
        if (shmptr^.grp.rtvwork[workNo].status = U_COM_FRST) and
           (shmptr^.grp.rtvwork[workNo].setTime > ts_min)    and
           (shmptr^.grp.rtvwork[workNo].setTime < ts_max)
        then begin
            // ���ǿ� �����ϴ� �����۾��� ���� setTime���� ���Ͽ� Return
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
        // start_time(Now or ��Ž�� ���� ord_no) ���� ���� �ð��� ���� �۾� Ȯ��
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

        // ���� RTV
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

            // Allocation RTV�� �޾ƾ� �� �۾��� ��ġ�� ��� ��� �Ҵ� ���ϰ� ����
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

        // split �Ͽ� �迭�� �Ҵ�.
        possibleStr := gSttnInfo[group_no][my_i].possible.Split(['#']);

        Break;
    end;

    Result := possibleStr;
end;

end.

