unit SimulationForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Grids,
   Buttons, ComCtrls, ExtCtrls, Dialogs, Menus, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TfmSimulation = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button5: TButton;
    Button6: TButton;
    Button9: TButton;
    Button10: TButton;
    Button13: TButton;
    Button14: TButton;
    Button3: TButton;
    Button4: TButton;
    Button11: TButton;
    Button12: TButton;
    Button7: TButton;
    Image1: TImage;
    Button8: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    pnlRtv1: TPanel;
    Image2: TImage;
    Label1: TLabel;
    pnlRtv2: TPanel;
    Image3: TImage;
    Label2: TLabel;
    shpload_1: TShape;
    shpload_2: TShape;
    Panel8: TPanel;
    Panel9: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edpos_2: TEdit;
    edDest_2: TEdit;
    Label6: TLabel;
    edDest_1: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    edpos_1: TEdit;
    Button21: TButton;
    pos_1: TShape;
    pos_2: TShape;
    pos_5: TShape;
    pos_6: TShape;
    pos_3: TShape;
    pos_8: TShape;
    pos_9: TShape;
    pos_10: TShape;
    pos_11: TShape;
    pos_12: TShape;
    pos_13: TShape;
    pos_14: TShape;
    pos_15: TShape;
    pos_16: TShape;
    pos_4: TShape;
    pos_7: TShape;
    Button22: TButton;
    Button23: TButton;
    TimerComm: TTimer;
    TimerWork: TTimer;
    edMoveInterval: TEdit;
    edCommInterval: TEdit;
    edWorkInterval: TEdit;
    TimerStatus: TTimer;
    TimerMove: TTimer;
    Button24: TButton;
    Shape3: TShape;
    shpMove: TShape;
    shpComm: TShape;
    Shape5: TShape;
    Shape6: TShape;
    shpWork: TShape;
    Panel6: TPanel;
    Button25: TButton;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    edWork_2: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    cbStatus_2: TComboBox;
    cbStatus_1: TComboBox;
    cbExist_2: TComboBox;
    cbExist_1: TComboBox;
    edWork_1: TEdit;
    cbOrder_2: TComboBox;
    cbOrder_1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure TimerMoveTimer(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure TimerCommTimer(Sender: TObject);
    procedure TimerWorkTimer(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses hmx.constant, hmx.define, cs_rtv;

var
    g_rtv_station_working_counter : array[1..U_MAX_RTV] of Integer;
    rtvtiles : array[1..U_MAX_RTV] of TImage;

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TfmSimulation.Button21Click(Sender: TObject);
begin
    TimerMove.Interval := StrTointDef(edMoveInterval.Text, 0);

    if TimerMove.Enabled = True
    then begin
        TimerMove.Enabled := False;
        shpMove.Brush.Color := clRed;
    end
    else begin
        TimerMove.Enabled := True;
        shpMove.Brush.Color := clLime;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.Button22Click(Sender: TObject);
begin
    TimerComm.Interval := StrTointDef(edCommInterval.Text, 0);

    if TimerComm.Enabled = True
    then begin
        TimerComm.Enabled := False;
        shpComm.Brush.Color := clRed;
    end
    else begin
        TimerComm.Enabled := True;
        shpComm.Brush.Color := clLime;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.Button23Click(Sender: TObject);
begin
    TimerWork.Interval := StrTointDef(edWorkInterval.Text, 0);

    if TimerWork.Enabled = True
    then begin
        TimerWork.Enabled := False;
        shpWork.Brush.Color := clRed;
    end
    else begin
        TimerWork.Enabled := True;
        shpWork.Brush.Color := clLime;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.Button24Click(Sender: TObject);
begin
    FillChar(shmptr^.grp.rtvwork, SizeOf(shmptr^.grp.rtvwork), 0);
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.Button25Click(Sender: TObject);
begin
    Panel6.Visible := False;
end;

//------------------------------------------------------------------------------
// Form Create Event
//------------------------------------------------------------------------------
procedure TfmSimulation.FormCreate(Sender: TObject);
var
    rtv_pos_1, rtv_pos_2 : Integer;
begin
    TimerWork.Enabled := False;
    TimerComm.Enabled := False;
    TimerMove.Enabled := False;

    shpWork.Brush.Color := clRed;
    shpComm.Brush.Color := clRed;
    shpMove.Brush.Color := clRed;

    edWorkInterval.Text := IntToStr(TimerWork.Interval);
    edCommInterval.Text := IntToStr(TimerComm.Interval);
    edMoveInterval.Text := IntToStr(TimerMove.Interval);

    rtv_pos_1 := shmptr^.grp.rtvinfo[1].currentPosition;
    rtv_pos_2 := shmptr^.grp.rtvinfo[2].currentPosition;


    TPanel(FindComponent('pnlRtv' + IntToStr(1))).Top := TShape(FindComponent('pos_' + IntToStr(station_to_position(1, rtv_pos_1)))).Top-40;
    Tedit(FindComponent('edpos_' + IntToStr(1))).Text := IntToStr(station_to_position(1, rtv_pos_1));
    TPanel(FindComponent('pnlRtv' + IntToStr(2))).Top := TShape(FindComponent('pos_' + IntToStr(station_to_position(1, rtv_pos_2)))).Top-40;
    Tedit(FindComponent('edpos_' + IntToStr(2))).Text := IntToStr(station_to_position(1, rtv_pos_2));
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.TimerCommTimer(Sender: TObject);
var
     ord_no, rtvNo, rtv_pos, status, exists, workNo, orderClass : Integer;
begin
    TimerComm.Enabled := False;

    try
        for ord_no := 1 to U_MAX_WORK do
        begin
            // -------------------------------------------------------------
            // RTV
            // -------------------------------------------------------------
            if (shmptr^.grp.rtvwork[ord_no].status = U_COM_WAIT) or
               (shmptr^.grp.rtvwork[ord_no].status = U_COM_LOAD) or
               (shmptr^.grp.rtvwork[ord_no].status = U_COM_PEND)
            then begin
                rtvNo := shmptr^.grp.rtvwork[ord_no].rtvNo;
                rtv_pos := 0;
                workNo := shmptr^.grp.rtvwork[ord_no].workNo;

                if shmptr^.grp.rtvinfo[rtvNo].status = U_RTV_STAT_REDY  then status := 0 else status := 1;
                if shmptr^.grp.rtvinfo[rtvNo].exists[1]                 then exists := 1 else exists := 0;

                // ORDER CLASS 설정
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_MOVE then orderClass := 0;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_LOAD then orderClass := 1;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_UNLD then orderClass := 2;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_TRAN then orderClass := 3;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_HOME then orderClass := 4;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_ONLI then orderClass := 5;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_RSET then orderClass := 6;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_STOP then orderClass := 7;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_CLAR then orderClass := 8;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_MNDR then orderClass := 9;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_EMRY then orderClass := 10;
                if shmptr^.grp.rtvwork[ord_no].orderClass = U_RTV_FNC_CPRS then orderClass := 11;

                if shmptr^.grp.rtvwork[ord_no].status = U_COM_WAIT
                then rtv_pos := shmptr^.grp.rtvwork[ord_no].fromStation
                else if shmptr^.grp.rtvwork[ord_no].status = U_COM_LOAD
                then rtv_pos := shmptr^.grp.rtvwork[ord_no].toStation;

                Tedit(FindComponent('eddest_' + IntToStr(rtvNo))).Text :=
                                      IntToStr(station_to_position(1, rtv_pos));

                Tedit(FindComponent('edWork_' + IntToStr(rtvNo))).Text :=
                                      IntToStr(workNo);

                TComboBox(FindComponent('cbOrder_' + IntToStr(rtvNo))).ItemIndex := orderClass;

                TComboBox(FindComponent('cbStatus_' + IntToStr(rtvNo))).ItemIndex := status;

                TComboBox(FindComponent('cbExist_' + IntToStr(rtvNo))).ItemIndex := exists;

                shmptr^.grp.rtvwork[ord_no].status := U_COM_COMT;
                shmptr^.grp.rtvinfo[rtvNo].status := U_RTV_STAT_WORK;
            end;
        end;

        for rtvNo := 1 to U_MAX_RTV do
        begin
            if shmptr^.grp.rtvmove[rtvNo].status = U_COM_WAIT
            then begin
                rtv_pos := shmptr^.grp.rtvmove[rtvNo].toStation;

                Tedit(FindComponent('eddest_' + IntToStr(rtvNo))).Text :=
                                      IntToStr(station_to_position(1, rtv_pos));

                shmptr^.grp.rtvmove[rtvNo].status := U_COM_NONE;
            end;
        end;
    finally
        TimerComm.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.TimerWorkTimer(Sender: TObject);
var
     ord_no, second : Integer;
     loadingSttn : array [1..14] of Integer;
     unloadingSttn : array [1..8] of Integer;
begin
    TimerWork.Enabled := False;

    loadingSttn[1]  := 1;
    loadingSttn[2]  := 3;
    loadingSttn[3]  := 4;
    loadingSttn[4]  := 5;
    loadingSttn[5]  := 7;
    loadingSttn[6]  := 8;
    loadingSttn[7]  := 9;
    loadingSttn[8]  := 11;
    loadingSttn[9]  := 12;
    loadingSttn[10] := 13;
    loadingSttn[11] := 15;
    loadingSttn[12] := 16;
    loadingSttn[13] := 17;
    loadingSttn[14] := 20;

    unloadingSttn[1]  := 2;
    unloadingSttn[2]  := 3;
    unloadingSttn[3]  := 4;
    unloadingSttn[4]  := 6;
    unloadingSttn[5]  := 10;
    unloadingSttn[6]  := 14;
    unloadingSttn[7]  := 19;
    unloadingSttn[8]  := 21;

    try
        for ord_no := 1 to U_MAX_WORK do
        begin
            // -------------------------------------------------------------
            // RTV         
            // -------------------------------------------------------------
            if shmptr^.grp.rtvwork[ord_no].status = U_COM_NONE
            then begin
                second := StrToInt(FormatDatetime('ss', now));
                shmptr^.grp.rtvwork[ord_no].fromStation := loadingSttn[(second mod 14) + 1];
                shmptr^.grp.rtvwork[ord_no].toStation := unloadingSttn[(second mod 8) + 1];

                if shmptr^.grp.rtvwork[ord_no].fromStation =
                   shmptr^.grp.rtvwork[ord_no].toStation
                then Continue;

                shmptr^.grp.rtvwork[ord_no].orderClass := U_RTV_FNC_LOAD;

                shmptr^.grp.rtvwork[ord_no].workNo := ord_no;
                shmptr^.grp.rtvwork[ord_no].status := U_COM_FRST;
		
		        shmptr^.grp.rtvwork[ord_no].setTime := Now;
                Break;
            end;
        end;
    finally
        TimerWork.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmSimulation.TimerMoveTimer(Sender: TObject);
var
    pos, dest, rtvNo, workNo, covWorkNo : Integer;
begin
    TimerMove.Enabled := False;

    try
        for rtvNo := 1 to U_MAX_RTV do
        begin
            pos := StrToIntdef(Tedit(FindComponent('edpos_' + IntToStr(rtvNo))).Text, -1);

            if pos < 0
            then Continue;

            dest := StrToIntdef(Tedit(FindComponent('eddest_' + IntToStr(rtvNo))).Text, -1);

            if dest < 0
            then Continue;

            rtvtiles[1] := TImage(FindComponent('Image2'));
            rtvtiles[2] := TImage(FindComponent('Image3'));

            if shmptr^.grp.rtvinfo[rtvNo].status = U_RTV_STAT_REDY
            then begin
                // 노란색 RTV 표기
                rtvtiles[rtvNo].Picture.LoadFromFile('C:\Project\HMX_GROUP_CONTROLLER\file\img\RTV_01.png');
            end
            else if shmptr^.grp.rtvinfo[rtvNo].status = U_RTV_STAT_WORK
            then begin
                // 파란색 RTV 표기
                rtvtiles[rtvNo].Picture.LoadFromFile('C:\Project\HMX_GROUP_CONTROLLER\file\img\RTV_02.png');
            end;


            //if g_rtv_station_working_counter[rtvNo] > 3
            //then begin
            for workNo := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[workNo].rtvNo <> rtvNo
                then Continue;

                covWorkNo := shmptr^.grp.rtvwork[workNo].workNo;

                {if (pos = station_to_position(1, shmptr^.grp.rtvwork[workNo].fromStation)) and
                   (shmptr^.grp.rtvwork[covWorkNo].orderClass = U_RTV_FNC_LOAD)
                then shmptr^.grp.rtvinfo[rtvNo].exists[1] := True;

                if pos = station_to_position(1, shmptr^.grp.rtvwork[workNo].ToStation)
                then shmptr^.grp.rtvinfo[rtvNo].exists[1] := False;    }
            end;
            //end
            //else begin
            //    g_rtv_station_working_counter[rtvNo] := g_rtv_station_working_counter[rtvNo] + 1;
            //end;

            if pos < dest
            then begin
                TPanel(FindComponent('pnlRtv' + IntToStr(rtvNo))).Top := TShape(FindComponent('pos_' + IntToStr(pos + 1))).Top-40;
                Tedit(FindComponent('edpos_' + IntToStr(rtvNo))).Text := IntToStr(pos + 1);
            end
            else if pos > dest
            then begin
                TPanel(FindComponent('pnlRtv' + IntToStr(rtvNo))).Top := TShape(FindComponent('pos_' + IntToStr(pos - 1))).Top-40;
                Tedit(FindComponent('edpos_' + IntToStr(rtvNo))).Text := IntToStr(pos - 1);
            end
            else if (pos = dest) and
                    (shmptr^.grp.rtvwork[covWorkNo].orderClass = U_RTV_FNC_LOAD) and
                    (shmptr^.grp.rtvinfo[rtvNo].status = U_RTV_STAT_WORK) and
                    (shmptr^.grp.rtvwork[covWorkNo].status = U_COM_EXEC)
            then begin
                if g_rtv_station_working_counter[rtvNo] > 3
                then begin
                    for workNo := 1 to U_MAX_WORK do
                    begin
                        if shmptr^.grp.rtvwork[workNo].rtvNo <> rtvNo
                        then Continue;
                        if pos = station_to_position(1, shmptr^.grp.rtvwork[workNo].fromStation)
                        then begin
                            shmptr^.grp.rtvinfo[rtvNo].exists[1] := True;
                            shmptr^.grp.rtvinfo[rtvNo].status := U_RTV_STAT_REDY;
                            g_rtv_station_working_counter[rtvNo] := 0;
                        end;
                    end;
                end
                else begin
                    g_rtv_station_working_counter[rtvNo] := g_rtv_station_working_counter[rtvNo] + 1;
                end;
            end
            else if (pos = dest) and
                    (shmptr^.grp.rtvinfo[rtvNo].status = U_RTV_STAT_WORK) and
                    (shmptr^.grp.rtvwork[covWorkNo].status = U_COM_EXEC)
            then begin
                if g_rtv_station_working_counter[rtvNo] > 3
                then begin
                    for workNo := 1 to U_MAX_WORK do
                    begin
                        if shmptr^.grp.rtvwork[workNo].rtvNo <> rtvNo
                        then Continue;
                        if pos = station_to_position(1, shmptr^.grp.rtvwork[workNo].ToStation)
                        then begin
                            shmptr^.grp.rtvinfo[rtvNo].exists[1] := False;
                            shmptr^.grp.rtvinfo[rtvNo].status := U_RTV_STAT_REDY;
                            g_rtv_station_working_counter[rtvNo] := 0;
                        end;
                    end;
                end
                else begin
                    g_rtv_station_working_counter[rtvNo] := g_rtv_station_working_counter[rtvNo] + 1;
                end;
            end;

            shmptr^.grp.rtvinfo[rtvNo].currentPosition := position_to_station(1, pos);

            TShape(FindComponent('shpload_' + IntToStr(rtvNo))).Visible := shmptr^.grp.rtvinfo[rtvNo].exists[1];
        end;

        if edpos_1.Text = edpos_2.Text
        then Panel6.Visible := True;
    finally
        TimerMove.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
end.
