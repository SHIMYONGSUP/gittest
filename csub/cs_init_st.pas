unit cs_init_st;
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

procedure StationDefine;

implementation

uses hmx.constant, hmx.define;

//------------------------------------------------------------------------------
procedure StationDefine;
begin
//    with shmptr^.whs[U_MAX_WHS].stn do
//    begin
        // 컨베어 입고작업 스테이션 정의
//        cnv_in[1].stn_no  := 5;                 // 1층 완제품 입고
//        cnv_in[1].to_stn  := 6;
//        cnv_in[1].stn_id  := 1;                 // PLC Work Stn Id
//
//        cnv_in[2].stn_no  := 1;                 // 1층 부자재 입고
//        cnv_in[2].to_stn  := 2;
//        cnv_in[2].stn_id  := 2;                 // PLC Work Stn Id
//
//        cnv_in[3].stn_no  := 9;                 // 2층 부자재 입고
//        cnv_in[3].to_stn  := 10;
//        cnv_in[3].stn_id  := 3;                 // PLC Work Stn Id
//
//        // * 고정식바코드 스캐너 위치 확인 후 수정 *
//        cnv_in[4].stn_no  := 18;                // 3층 완제품 입고
//        cnv_in[4].to_stn  := 14;
//        cnv_in[4].stn_id  := 4;                 // PLC Work Stn Id
//
//        // AGV -> 창고 Unlaoding S/T (완제품)
//        cnv_in[5].stn_no  := 13;                //
//        cnv_in[5].to_stn  := 14;
//        cnv_in[5].stn_id  := 5;                 // PLC Work Stn Id
//
//        // AGV -> 창고 Unlaoding S/T (Empty Pallet)
//        cnv_in[6].stn_no  := 23;                // Cell 라인 컨베어 #1
//        cnv_in[6].to_stn  := 14;
//        cnv_in[6].stn_id  := 6;                 // PLC Work Stn Id
//
//        // 스태커 출고 스테이션 정의    ls 현장 확인후 수정 (수정완료)
//        stc_ot[1].stn_no := 3;                  // 1층 완제품 출고
//        stc_ot[1].stc_ls := 4;                  // 스태어 L/S
//        stc_ot[1].stn_id := 7;                  // PLC Work Stn Id
//
//        stc_ot[2].stn_no := 7;                  // 1층 부자재 출고
//        stc_ot[2].stc_ls := 2;                  // 스태어 L/S
//        stc_ot[2].stn_id := 8;                 // PLC Work Stn Id
//
//        stc_ot[3].stn_no := 11;                 // 2층 부자재 출고
//        stc_ot[3].stc_ls := 6;                  // 스태어 L/S
//        stc_ot[3].stn_id := 9;                 // PLC Work Stn Id
//
//        stc_ot[4].stn_no := 15;                 // 3층 Cell 라인 출고
//        stc_ot[4].stc_ls := 8;                  // 스태어 L/S
//        stc_ot[4].stn_id := 10;                 // PLC Work Stn Id
//
//        // 스태커 입고 스테이션 정의    ls 현장 확인후 수정 (수정완료)
//        stc_in[1].stn_no := 6;                  // 1층 완제품 입고
//        stc_in[1].stc_ls := 3;                  // 스태어 L/S
//
//        stc_in[2].stn_no := 2;                  // 1층 부자재 입고
//        stc_in[2].stc_ls := 1;                  // 스태어 L/S
//
//        stc_in[3].stn_no := 10;                 // 2층 부자재 입고
//        stc_in[3].stc_ls := 5;                  // 스태어 L/S
//
//        stc_in[4].stn_no := 14;                 // 3층 완제품 입고
//        stc_in[4].stc_ls := 7;                  // 스태어 L/S
//
//
//        // 컨베어 작업완료 스테이션 정의
//        end_st[1].stn_no  := 4;                 // 1층 완제품 출고
//        end_st[2].stn_no  := 8;                 // 1층 부자재 출고
//        end_st[3].stn_no  := 12;                // 2층 부자재 출고
//        end_st[4].stn_no  := 16;                // 3층 부자재 출고 (16)
//        end_st[5].stn_no  := 20;                // 고정바코드 스캐너 AGV LOADING S/T
//        end_st[6].stn_no  := 26;                // Cell 라인 #1
//        end_st[7].stn_no  := 27;                // Cell 라인 #2
//        end_st[8].stn_no  := 28;                // Cell 라인 #3
//        end_st[9].stn_no  := 29;                // Cell 라인 #4
//        end_st[10].stn_no := 30;                // Cell 라인 #5
//        end_st[11].stn_no := 31;                // Cell 라인 #6
//        end_st[12].stn_no := 23;                // 3층 공파렛트 입고 AGV L/D S/T
//
//
//        // AGV Loading 스테이션 정의
//        // 부자재 출고 -> Cell 라인으로 출고시 목적지가 1 : N 으로 다양하게 있어서
//        // 정의할 수 없음.
//        agv_ld[1].agv_ps := 11;                 // 3층 Cell 라인 공급 Loading agv pos
//        agv_ld[1].to_pos := 0;                  // agv to pos
//        agv_ld[1].stn_no := 16;                 // station no.
//        agv_ld[1].to_stn := 0;                  // to station no
//
//        agv_ld[2].agv_ps := 42;                 // 3층 Empty pallet loading agv pos
//        agv_ld[2].to_pos := 61;                 // agv to pos
//        agv_ld[2].stn_no := 23;                 // station no.
//        agv_ld[2].to_stn := 14;                 // to station no
//
//        agv_ld[3].agv_ps := 51;                // 3층 완제품 Loading agv pos
//        agv_ld[3].to_pos := 61;                // agv to pos
//        agv_ld[3].stn_no := 20;                // station no.
//        agv_ld[3].to_stn := 14;                // to station no
//
//        agv_ld[4].agv_ps := 21;                 // Cell 라인 #1 공급 Loading agv pos
//        agv_ld[4].to_pos := 41;                 // agv to pos
//        agv_ld[4].stn_no := 26;                 // station no.
//        agv_ld[4].to_stn := 21;                 // to station no
//
//        agv_ld[5].agv_ps := 22;                 // Cell 라인 #2 공급 Loading agv pos
//        agv_ld[5].to_pos := 41;                 // agv to pos
//        agv_ld[5].stn_no := 27;                 // station no.
//        agv_ld[5].to_stn := 21;                 // to station no
//
//        agv_ld[6].agv_ps := 23;                 // Cell 라인 #3 공급 Loading agv pos
//        agv_ld[6].to_pos := 41;                 // agv to pos
//        agv_ld[6].stn_no := 28;                 // station no.
//        agv_ld[6].to_stn := 21;                 // to station no
//
//        agv_ld[7].agv_ps := 24;                 // Cell 라인 #4 공급 Loading agv pos
//        agv_ld[7].to_pos := 41;                 // agv to pos
//        agv_ld[7].stn_no := 29;                 // station no.
//        agv_ld[7].to_stn := 21;                 // to station no
//
//        agv_ld[8].agv_ps := 25;                 // Cell 라인 #5 공급 Loading agv pos
//        agv_ld[8].to_pos := 41;                 // agv to pos
//        agv_ld[8].stn_no := 30;                 // station no.
//        agv_ld[8].to_stn := 21;                 // to station no
//
//        agv_ld[9].agv_ps := 26;                 // Cell 라인 #6 공급 Loading agv pos
//        agv_ld[9].to_pos := 41;                 // agv to pos
//        agv_ld[9].stn_no := 31;                 // station no.
//        agv_ld[9].to_stn := 21;                 // to station no
//
//
//        // AGV Unloading 스테이션 정의
//        // Empty pallet Unloading 이후 Action 에 따라서 to_stn 수정.
//        agv_ud[1].agv_ps := 41;                 // 3층 Empty Pallet Unlaoding S/T
//        agv_ud[1].stn_no := 21;                 // sation no.
//        agv_ud[1].to_stn := 23;                 // to station no.
//        agv_ud[1].stn_id := 0;                  // PLC work Id
//
//        agv_ud[2].agv_ps := 61;                 // 3층 완제품 AGV->창고 Unloading S/T
//        agv_ud[2].stn_no := 13;                 // sation no.
//        agv_ud[2].to_stn := 14;                 // to station no.
//        agv_ud[2].stn_id := 0;                  // PLC work Id
//
//        agv_ud[3].agv_ps := 21;                 // Cell 라인 #1 Unloading agv pos
//        agv_ud[3].stn_no := 26;                 // sation no.
//        agv_ud[3].to_stn := 26;                 // to station no.
//        agv_ud[3].stn_id := 0;                  // PLC work Id
//
//        agv_ud[4].agv_ps := 22;                 // Cell 라인 #2
//        agv_ud[4].stn_no := 27;                 // sation no.
//        agv_ud[4].to_stn := 27;                 // to station no.
//        agv_ud[4].stn_id := 0;                  // PLC work Id
//
//        agv_ud[5].agv_ps := 23;                 // Cell 라인 #3
//        agv_ud[5].stn_no := 28;                 // sation no.
//        agv_ud[5].to_stn := 28;                 // to station no.
//        agv_ud[5].stn_id := 0;                  // PLC work Id
//
//        agv_ud[6].agv_ps := 24;                 // Cell 라인 #4
//        agv_ud[6].stn_no := 29;                 // sation no.
//        agv_ud[6].to_stn := 29;                 // to station no.
//        agv_ud[6].stn_id := 0;                  // PLC work Id
//
//        agv_ud[7].agv_ps := 25;                 // Cell 라인 #5
//        agv_ud[7].stn_no := 30;                 // sation no.
//        agv_ud[7].to_stn := 30;                 // to station no.
//        agv_ud[7].stn_id := 0;                  // PLC work Id
//
//        agv_ud[8].agv_ps := 26;                 // Cell 라인 #6
//        agv_ud[8].stn_no := 31;                 // sation no.
//        agv_ud[8].to_stn := 31;                 // to station no.
//        agv_ud[8].stn_id := 0;                  // PLC work Id
 //   end;
end;

end.
