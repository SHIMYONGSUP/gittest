unit ct_s010;

interface

procedure update_rtv_status(grp_no : Integer);

implementation

uses SysUtils, Windows, GlobalVar, GlobalFnc,
     MainForm, cs_misc, hmx.constant, hmx.define;

//------------------------------------------------------------------------------
procedure update_rtv_status(grp_no : Integer);
var
    rtv_no, ord_no : Integer;
begin

    for ord_no := 1 to U_MAX_WORK do
    begin
        {$REGION '로딩작업 상태변경'}
        // COMT -> EXEC
        if (shmptr^.grp.rtvwork[ord_no].status = U_COM_COMT) and
           (shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_LOAD)
        then begin
            // 작업 중인 호기
            rtv_no := shmptr^.grp.rtvwork[ord_no].rtvNo;

            // RTV 상태  (1:대기, 2:작중)
            // 화물 감지 확인
            if (shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_WORK) and
               (shmptr^.grp.rtvinfo[rtv_no].exists[1] = False)
            then begin
                shmptr^.grp.rtvwork[ord_no].status := U_COM_EXEC;

                ctl_display('  Loading ' +
                            ' GRP NO:'    + IntToStr(grp_no) +
                            ' RTV NO:'    + IntToStr(rtv_no) +
                            ' FROM POS: ' + IntToStr(shmptr^.grp.rtvwork[ord_no].fromStation) +
                            ' TO POS: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].toStation) +
                            ' SERIAL: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].workNo) +
                            ' U_COM_COMT -> U_COM_EXEC');
            end;
        end;

        // EXEC -> REST
        if (shmptr^.grp.rtvwork[ord_no].status = U_COM_EXEC) and
           (shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_LOAD)
        then begin
            // 작업 중인 호기
            rtv_no := shmptr^.grp.rtvwork[ord_no].rtvNo;

            if (shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_REDY) and
               (shmptr^.grp.rtvinfo[rtv_no].exists[1] = True)
            then begin
                shmptr^.grp.rtvwork[ord_no].orderClass := U_RTV_FNC_UNLD;

                shmptr^.grp.rtvwork[ord_no].status := U_COM_LOAD;

                ctl_display('  Loading ' +
                            ' GRP NO:'    + IntToStr(grp_no) +
                            ' RTV NO:'    + IntToStr(rtv_no) +
                            ' FROM POS: ' + IntToStr(shmptr^.grp.rtvwork[ord_no].fromStation) +
                            ' TO POS: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].toStation) +
                            ' SERIAL: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].workNo) +
                            ' U_COM_EXEC -> U_COM_LOAD');
            end;
        end;

        {$ENDREGION}

        {$REGION '언로딩작업 상태변경'}
        // COMT -> EXEC
        if (shmptr^.grp.rtvwork[ord_no].status = U_COM_COMT) and
           (shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_UNLD)
        then begin
            // 작업 중인 호기
            rtv_no := shmptr^.grp.rtvwork[ord_no].rtvNo;

            // RTV 상태  (1:대기, 2:작중)
            if shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_WORK
            then begin
                shmptr^.grp.rtvwork[ord_no].status := U_COM_EXEC;

                ctl_display('  Unloading ' +
                            ' GRP NO:'    + IntToStr(grp_no) +
                            ' RTV NO:'    + IntToStr(rtv_no) +
                            ' FROM POS: ' + IntToStr(shmptr^.grp.rtvwork[ord_no].fromStation) +
                            ' TO POS: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].toStation) +
                            ' SERIAL: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].workNo) +
                            ' U_COM_COMT -> U_COM_EXEC');
            end;
        end;

        // EXEC -> COMP
        if (shmptr^.grp.rtvwork[ord_no].status = U_COM_EXEC) and
           (shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_UNLD)
        then begin
             // 작업 중인 호기
            rtv_no := shmptr^.grp.rtvwork[ord_no].rtvNo;

            // RTV 상태  (1:대기, 2:작중)
            // 화물감지 X
            if (shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_REDY) and
               (shmptr^.grp.rtvinfo[rtv_no].exists[1] = False)
            then begin
                // RTV COMP 으로 수정해야 함.
                { TODO : 나중에 수정해야 함. }
                shmptr^.grp.rtvwork[ord_no].status := U_COM_NONE;
                FillChar(shmptr^.grp.rtvwork[ord_no], sizeof(shmptr^.grp.rtvwork[ord_no]), 0);

                ctl_display('  Unloading ' +
                            ' GRP NO:'    + IntToStr(grp_no) +
                            ' RTV NO:'    + IntToStr(rtv_no) +
                            ' FROM POS: ' + IntToStr(shmptr^.grp.rtvwork[ord_no].fromStation) +
                            ' TO POS: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].toStation) +
                            ' SERIAL: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].workNo)    +
                            ' U_COM_EXEC -> U_COM_COMP');
            end;
        end;

        { TODO : 나중에 살려야 함. }
        // COMP -> NONE
        {if (shmptr^.grp.rtvwork[ord_no].status = U_COM_COMP) and
           (shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_UNLD)
        then begin
             // 작업 중인 호기
            rtv_no := shmptr^.grp.rtvwork[ord_no].rtvNo;

            // RTV 상태  (1:대기, 2:작중)
            // 화물감지 X
            if (shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_REDY) and
               (shmptr^.grp.rtvinfo[rtv_no].exists[1] = False)
            then begin
                shmptr^.grp.rtvwork[ord_no].status := U_COM_COMP;

                ctl_display('  Unloading ' +
                            ' GRP NO:'    + IntToStr(grp_no) +
                            ' RTV NO:'    + IntToStr(rtv_no) +
                            ' FROM POS: ' + IntToStr(shmptr^.grp.rtvwork[ord_no].fromStation) +
                            ' TO POS: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].toStation) +
                            ' SERIAL: '   + IntToStr(shmptr^.grp.rtvwork[ord_no].workNo)    +
                            ' U_COM_EXEC -> U_COM_COMP');
            end;
        end;}

        {$ENDREGION}
    end;
end;

end.

