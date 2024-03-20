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
        // ������ �԰��۾� �����̼� ����
//        cnv_in[1].stn_no  := 5;                 // 1�� ����ǰ �԰�
//        cnv_in[1].to_stn  := 6;
//        cnv_in[1].stn_id  := 1;                 // PLC Work Stn Id
//
//        cnv_in[2].stn_no  := 1;                 // 1�� ������ �԰�
//        cnv_in[2].to_stn  := 2;
//        cnv_in[2].stn_id  := 2;                 // PLC Work Stn Id
//
//        cnv_in[3].stn_no  := 9;                 // 2�� ������ �԰�
//        cnv_in[3].to_stn  := 10;
//        cnv_in[3].stn_id  := 3;                 // PLC Work Stn Id
//
//        // * �����Ĺ��ڵ� ��ĳ�� ��ġ Ȯ�� �� ���� *
//        cnv_in[4].stn_no  := 18;                // 3�� ����ǰ �԰�
//        cnv_in[4].to_stn  := 14;
//        cnv_in[4].stn_id  := 4;                 // PLC Work Stn Id
//
//        // AGV -> â�� Unlaoding S/T (����ǰ)
//        cnv_in[5].stn_no  := 13;                //
//        cnv_in[5].to_stn  := 14;
//        cnv_in[5].stn_id  := 5;                 // PLC Work Stn Id
//
//        // AGV -> â�� Unlaoding S/T (Empty Pallet)
//        cnv_in[6].stn_no  := 23;                // Cell ���� ������ #1
//        cnv_in[6].to_stn  := 14;
//        cnv_in[6].stn_id  := 6;                 // PLC Work Stn Id
//
//        // ����Ŀ ��� �����̼� ����    ls ���� Ȯ���� ���� (�����Ϸ�)
//        stc_ot[1].stn_no := 3;                  // 1�� ����ǰ ���
//        stc_ot[1].stc_ls := 4;                  // ���¾� L/S
//        stc_ot[1].stn_id := 7;                  // PLC Work Stn Id
//
//        stc_ot[2].stn_no := 7;                  // 1�� ������ ���
//        stc_ot[2].stc_ls := 2;                  // ���¾� L/S
//        stc_ot[2].stn_id := 8;                 // PLC Work Stn Id
//
//        stc_ot[3].stn_no := 11;                 // 2�� ������ ���
//        stc_ot[3].stc_ls := 6;                  // ���¾� L/S
//        stc_ot[3].stn_id := 9;                 // PLC Work Stn Id
//
//        stc_ot[4].stn_no := 15;                 // 3�� Cell ���� ���
//        stc_ot[4].stc_ls := 8;                  // ���¾� L/S
//        stc_ot[4].stn_id := 10;                 // PLC Work Stn Id
//
//        // ����Ŀ �԰� �����̼� ����    ls ���� Ȯ���� ���� (�����Ϸ�)
//        stc_in[1].stn_no := 6;                  // 1�� ����ǰ �԰�
//        stc_in[1].stc_ls := 3;                  // ���¾� L/S
//
//        stc_in[2].stn_no := 2;                  // 1�� ������ �԰�
//        stc_in[2].stc_ls := 1;                  // ���¾� L/S
//
//        stc_in[3].stn_no := 10;                 // 2�� ������ �԰�
//        stc_in[3].stc_ls := 5;                  // ���¾� L/S
//
//        stc_in[4].stn_no := 14;                 // 3�� ����ǰ �԰�
//        stc_in[4].stc_ls := 7;                  // ���¾� L/S
//
//
//        // ������ �۾��Ϸ� �����̼� ����
//        end_st[1].stn_no  := 4;                 // 1�� ����ǰ ���
//        end_st[2].stn_no  := 8;                 // 1�� ������ ���
//        end_st[3].stn_no  := 12;                // 2�� ������ ���
//        end_st[4].stn_no  := 16;                // 3�� ������ ��� (16)
//        end_st[5].stn_no  := 20;                // �������ڵ� ��ĳ�� AGV LOADING S/T
//        end_st[6].stn_no  := 26;                // Cell ���� #1
//        end_st[7].stn_no  := 27;                // Cell ���� #2
//        end_st[8].stn_no  := 28;                // Cell ���� #3
//        end_st[9].stn_no  := 29;                // Cell ���� #4
//        end_st[10].stn_no := 30;                // Cell ���� #5
//        end_st[11].stn_no := 31;                // Cell ���� #6
//        end_st[12].stn_no := 23;                // 3�� ���ķ�Ʈ �԰� AGV L/D S/T
//
//
//        // AGV Loading �����̼� ����
//        // ������ ��� -> Cell �������� ���� �������� 1 : N ���� �پ��ϰ� �־
//        // ������ �� ����.
//        agv_ld[1].agv_ps := 11;                 // 3�� Cell ���� ���� Loading agv pos
//        agv_ld[1].to_pos := 0;                  // agv to pos
//        agv_ld[1].stn_no := 16;                 // station no.
//        agv_ld[1].to_stn := 0;                  // to station no
//
//        agv_ld[2].agv_ps := 42;                 // 3�� Empty pallet loading agv pos
//        agv_ld[2].to_pos := 61;                 // agv to pos
//        agv_ld[2].stn_no := 23;                 // station no.
//        agv_ld[2].to_stn := 14;                 // to station no
//
//        agv_ld[3].agv_ps := 51;                // 3�� ����ǰ Loading agv pos
//        agv_ld[3].to_pos := 61;                // agv to pos
//        agv_ld[3].stn_no := 20;                // station no.
//        agv_ld[3].to_stn := 14;                // to station no
//
//        agv_ld[4].agv_ps := 21;                 // Cell ���� #1 ���� Loading agv pos
//        agv_ld[4].to_pos := 41;                 // agv to pos
//        agv_ld[4].stn_no := 26;                 // station no.
//        agv_ld[4].to_stn := 21;                 // to station no
//
//        agv_ld[5].agv_ps := 22;                 // Cell ���� #2 ���� Loading agv pos
//        agv_ld[5].to_pos := 41;                 // agv to pos
//        agv_ld[5].stn_no := 27;                 // station no.
//        agv_ld[5].to_stn := 21;                 // to station no
//
//        agv_ld[6].agv_ps := 23;                 // Cell ���� #3 ���� Loading agv pos
//        agv_ld[6].to_pos := 41;                 // agv to pos
//        agv_ld[6].stn_no := 28;                 // station no.
//        agv_ld[6].to_stn := 21;                 // to station no
//
//        agv_ld[7].agv_ps := 24;                 // Cell ���� #4 ���� Loading agv pos
//        agv_ld[7].to_pos := 41;                 // agv to pos
//        agv_ld[7].stn_no := 29;                 // station no.
//        agv_ld[7].to_stn := 21;                 // to station no
//
//        agv_ld[8].agv_ps := 25;                 // Cell ���� #5 ���� Loading agv pos
//        agv_ld[8].to_pos := 41;                 // agv to pos
//        agv_ld[8].stn_no := 30;                 // station no.
//        agv_ld[8].to_stn := 21;                 // to station no
//
//        agv_ld[9].agv_ps := 26;                 // Cell ���� #6 ���� Loading agv pos
//        agv_ld[9].to_pos := 41;                 // agv to pos
//        agv_ld[9].stn_no := 31;                 // station no.
//        agv_ld[9].to_stn := 21;                 // to station no
//
//
//        // AGV Unloading �����̼� ����
//        // Empty pallet Unloading ���� Action �� ���� to_stn ����.
//        agv_ud[1].agv_ps := 41;                 // 3�� Empty Pallet Unlaoding S/T
//        agv_ud[1].stn_no := 21;                 // sation no.
//        agv_ud[1].to_stn := 23;                 // to station no.
//        agv_ud[1].stn_id := 0;                  // PLC work Id
//
//        agv_ud[2].agv_ps := 61;                 // 3�� ����ǰ AGV->â�� Unloading S/T
//        agv_ud[2].stn_no := 13;                 // sation no.
//        agv_ud[2].to_stn := 14;                 // to station no.
//        agv_ud[2].stn_id := 0;                  // PLC work Id
//
//        agv_ud[3].agv_ps := 21;                 // Cell ���� #1 Unloading agv pos
//        agv_ud[3].stn_no := 26;                 // sation no.
//        agv_ud[3].to_stn := 26;                 // to station no.
//        agv_ud[3].stn_id := 0;                  // PLC work Id
//
//        agv_ud[4].agv_ps := 22;                 // Cell ���� #2
//        agv_ud[4].stn_no := 27;                 // sation no.
//        agv_ud[4].to_stn := 27;                 // to station no.
//        agv_ud[4].stn_id := 0;                  // PLC work Id
//
//        agv_ud[5].agv_ps := 23;                 // Cell ���� #3
//        agv_ud[5].stn_no := 28;                 // sation no.
//        agv_ud[5].to_stn := 28;                 // to station no.
//        agv_ud[5].stn_id := 0;                  // PLC work Id
//
//        agv_ud[6].agv_ps := 24;                 // Cell ���� #4
//        agv_ud[6].stn_no := 29;                 // sation no.
//        agv_ud[6].to_stn := 29;                 // to station no.
//        agv_ud[6].stn_id := 0;                  // PLC work Id
//
//        agv_ud[7].agv_ps := 25;                 // Cell ���� #5
//        agv_ud[7].stn_no := 30;                 // sation no.
//        agv_ud[7].to_stn := 30;                 // to station no.
//        agv_ud[7].stn_id := 0;                  // PLC work Id
//
//        agv_ud[8].agv_ps := 26;                 // Cell ���� #6
//        agv_ud[8].stn_no := 31;                 // sation no.
//        agv_ud[8].to_stn := 31;                 // to station no.
//        agv_ud[8].stn_id := 0;                  // PLC work Id
 //   end;
end;

end.
