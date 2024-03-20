unit RtvMoveBufferUpdate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls, System.UITypes,
  Vcl.Samples.Spin, hmx.define, hmx.constant, Vcl.Grids, Vcl.ComCtrls;

type
  TfmRtvMoveBufferUpdate = class(TForm)
    TimerDisplay: TTimer;
    tabType: TTabControl;
    Panel3: TPanel;
    Label17: TLabel;
    Label9: TLabel;
    Label110: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    btnOrderUpdate2: TSpeedButton;
    Autocheck: TCheckBox;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edWorkNo: TEdit;
    cbOrderClass: TComboBox;
    edFromStation: TEdit;
    edToStation: TEdit;
    cbPriority: TComboBox;
    cbStatus: TComboBox;
    edRtvNo: TEdit;
    edRowNo: TEdit;
    asgList: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerDisplayTimer(Sender: TObject);
    procedure DisplayInfo();
    procedure tabTypeChange(Sender: TObject);
    procedure btnOrderUpdate2Click(Sender: TObject);
    procedure asgListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmRtvMoveBufferUpdate: TfmRtvMoveBufferUpdate;

  g_flr_no : Integer;

implementation

uses cs_rtv;

{$R *.dfm}
//------------------------------------------------------------------------------
// Form Create Event
//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.FormCreate(Sender: TObject);
begin
    asgList.RowCount := U_MAX_RTV_MANUAL+1;

    asgList.Cells[1,  0] := 'Work No';
    asgList.Cells[2,  0] := 'Order Class';
    asgList.Cells[3,  0] := 'From';
    asgList.Cells[4,  0] := 'Fr Pos';
    asgList.Cells[5,  0] := 'To Pos';
    asgList.Cells[6,  0] := 'To';
    asgList.Cells[7,  0] := 'Priority';
    asgList.Cells[8,  0] := 'Status';
    asgList.Cells[9,  0] := 'Rtv No';
    asgList.Cells[10, 0] := 'PassCnt';
    asgList.Cells[11, 0] := 'Set Date';

    asgList.ColWidths[0] := 40;
    asgList.ColWidths[1] := 70;
    asgList.ColWidths[2] := 100;
    asgList.ColWidths[3] := 60;
    asgList.ColWidths[4] := 60;
    asgList.ColWidths[5] := 60;
    asgList.ColWidths[6] := 60;
    asgList.ColWidths[7] := 80;
    asgList.ColWidths[8] := 70;
    asgList.ColWidths[9] := 70;
    asgList.ColWidths[10] := 70;
    asgList.ColWidths[11] := 180;



    g_flr_no := 1;

    TimerDisplay.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.tabTypeChange(Sender: TObject);
begin
   g_flr_no := tabType.TabIndex + 1;
   // Info Display
   DisplayInfo();
end;

//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

//------------------------------------------------------------------------------
// Timer Event
//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.TimerDisplayTimer(Sender: TObject);
begin
    // Timer off
    TimerDisplay.Enabled := False;

    try
    // Auto Refresh Check
        if AutoCheck.Checked = False
        then begin
            edWorkNo.Enabled        := true;
            cbOrderClass.Enabled    := true;
            edFromStation.Enabled   := true;
            edToStation.Enabled     := true;
            cbPriority.Enabled      := true;
            cbStatus.Enabled        := true;
            edRtvNo.Enabled         := true;
            edRowNo.Enabled         := false;
            btnOrderUpdate2.Enabled := true;
            Exit;
        end
        else begin
            edWorkNo.Enabled        := false;
            cbOrderClass.Enabled    := false;
            edFromStation.Enabled   := false;
            edToStation.Enabled     := false;
            cbPriority.Enabled      := false;
            cbStatus.Enabled        := false;
            edRtvNo.Enabled         := false;
            edRowNo.Enabled         := false;
            btnOrderUpdate2.Enabled := false;
        end;
        // Info Display
        DisplayInfo();
    finally
        // Timer On
        TimerDisplay.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.asgListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
    order_class, status : Integer;
begin
    asgList.Cells[1,  ARow];
    status := 0;
    order_class := 1;

    if asgList.Cells[2,  ARow] = 'MOVE' then order_class := 1;
    if asgList.Cells[2,  ARow] = 'LOAD' then order_class := 2;
    if asgList.Cells[2,  ARow] = 'UNLD' then order_class := 3;
    if asgList.Cells[2,  ARow] = 'TRAN' then order_class := 4;
    if asgList.Cells[2,  ARow] = 'HOME' then order_class := 5;
    if asgList.Cells[2,  ARow] = 'ONLI' then order_class := 6;
    if asgList.Cells[2,  ARow] = 'RSET' then order_class := 7;
    if asgList.Cells[2,  ARow] = 'STOP' then order_class := 8;
    if asgList.Cells[2,  ARow] = 'CLAR' then order_class := 9;
    if asgList.Cells[2,  ARow] = 'MNDR' then order_class := 10;
    if asgList.Cells[2,  ARow] = 'EMRY' then order_class := 11;
    if asgList.Cells[2,  ARow] = 'CPRS' then order_class := 12;

    if asgList.Cells[6,  ARow] = 'NONE' then status := 0;
    if asgList.Cells[6,  ARow] = 'FRST' then status := 1;
    if asgList.Cells[6,  ARow] = 'RESV' then status := 2;
    if asgList.Cells[6,  ARow] = 'WAIT' then status := 3;
    if asgList.Cells[6,  ARow] = 'PEND' then status := 4;
    if asgList.Cells[6,  ARow] = 'COMT' then status := 5;
    if asgList.Cells[6,  ARow] = 'EXEC' then status := 6;
    if asgList.Cells[6,  ARow] = 'LOAD' then status := 7;
    if asgList.Cells[6,  ARow] = 'COMP' then status := 8;
    if asgList.Cells[6,  ARow] = 'REST' then status := 9;
    if asgList.Cells[6,  ARow] = 'EROR' then status := 10;
    if asgList.Cells[6,  ARow] = 'RETY' then status := 11;
    if asgList.Cells[6,  ARow] = 'RECT' then status := 12;

    edWorkNo.Text             := asgList.Cells[1,  ARow];
    cbOrderClass.ItemIndex    := order_class-1;
    edFromStation.Text        := asgList.Cells[3,  ARow];
    edToStation.Text          := asgList.Cells[4,  ARow];
    cbPriority.ItemIndex      := StrToInt(asgList.Cells[5,  ARow])-1;
    cbStatus.ItemIndex        := status;
    edRtvNo.Text              := asgList.Cells[7,  ARow];
    edRowNo.Text              := IntToStr(ARow);
end;

//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.btnOrderUpdate2Click(Sender: TObject);
var
    index : Integer;
begin
    index := tabType.TabIndex + 1;

    // Manual
    shmptr^.grp.rtvmove[index].workNo := StrToIntDef(edWorkNo.Text, 0);
    shmptr^.grp.rtvmove[index].orderClass := cbOrderClass.ItemIndex+1;
    shmptr^.grp.rtvmove[index].fromStation := StrToIntDef(edFromStation.Text, 0);
    shmptr^.grp.rtvmove[index].toStation := StrToIntDef(edToStation.Text, 0);
    shmptr^.grp.rtvmove[index].orderPriority := cbPriority.ItemIndex+1;
    shmptr^.grp.rtvmove[index].Status := cbStatus.ItemIndex;
    shmptr^.grp.rtvmove[index].rtvNo := StrToIntDef(edRtvNo.Text, 0);
end;

//------------------------------------------------------------------------------
procedure TfmRtvMoveBufferUpdate.DisplayInfo();
var
    idx_no, index : Integer;
    status, orderClass : String;
begin
    try
        for idx_no := 1 to U_MAX_RTV_MANUAL+1 do
        begin
            index := tabType.TabIndex+1;

            asgList.RowCount := 2;

            if shmptr^.grp.rtvmove[index].Status = U_COM_NONE then status := 'NONE';
            if shmptr^.grp.rtvmove[index].Status = U_COM_FRST then status := 'FRST';
            if shmptr^.grp.rtvmove[index].Status = U_COM_RESV then status := 'RESV';
            if shmptr^.grp.rtvmove[index].Status = U_COM_WAIT then status := 'WAIT';
            if shmptr^.grp.rtvmove[index].Status = U_COM_PEND then status := 'PEND';
            if shmptr^.grp.rtvmove[index].Status = U_COM_COMT then status := 'COMT';
            if shmptr^.grp.rtvmove[index].Status = U_COM_EXEC then status := 'EXEC';
            if shmptr^.grp.rtvmove[index].Status = U_COM_LOAD then status := 'LOAD';
            if shmptr^.grp.rtvmove[index].Status = U_COM_COMP then status := 'COMP';
            if shmptr^.grp.rtvmove[index].Status = U_COM_REST then status := 'REST';
            if shmptr^.grp.rtvmove[index].Status = U_COM_EROR then status := 'EROR';
            if shmptr^.grp.rtvmove[index].Status = U_COM_RTRY then status := 'RETY';
            if shmptr^.grp.rtvmove[index].Status = U_COM_RECT then status := 'RECT';

            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_MOVE then orderClass := 'MOVE';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_LOAD then orderClass := 'LOAD';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_UNLD then orderClass := 'UNLD';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_TRAN then orderClass := 'TRAN';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_HOME then orderClass := 'HOME';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_ONLI then orderClass := 'ONLI';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_RSET then orderClass := 'RSET';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_STOP then orderClass := 'STOP';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_CLAR then orderClass := 'CLAR';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_MNDR then orderClass := 'MNDR';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_EMRY then orderClass := 'EMRY';
            if shmptr^.grp.rtvmove[index].orderClass = U_RTV_FNC_CPRS then orderClass := 'CPRS';

            asgList.Cells[0,  1] := IntToStr(idx_no-1);
            asgList.Cells[1,  1] := IntToStr(shmptr^.grp.rtvmove[index].workNo);
            asgList.Cells[2,  1] := orderClass;
            asgList.Cells[3,  1] := IntToStr(shmptr^.grp.rtvmove[index].fromStation);
            asgList.Cells[4,  1] := IntToStr(station_to_position(1, shmptr^.grp.rtvmove[idx_no].fromStation));
            asgList.Cells[5,  1] := IntToStr(shmptr^.grp.rtvmove[index].toStation);
            asgList.Cells[6,  1] := IntToStr(station_to_position(1, shmptr^.grp.rtvmove[idx_no].toStation));
            asgList.Cells[7,  1] := IntToStr(shmptr^.grp.rtvmove[index].orderPriority);
            asgList.Cells[8,  1] := status;
            asgList.Cells[9,  1] := IntToStr(shmptr^.grp.rtvmove[index].rtvNo);
            asgList.Cells[10, 1] := IntToStr(shmptr^.grp.rtvmove[idx_no].passCount);
            asgList.Cells[11, 1] := DateTimeToStr(shmptr^.grp.rtvmove[idx_no].setTime);
        end;
    except on e: Exception do
        begin
            ShowMessage(e.Message);
        end;
    end;

end;
end.

