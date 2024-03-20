unit RtvOrderBufferUpdate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls, System.UITypes,
  Vcl.Samples.Spin, hmx.define, hmx.constant, Vcl.Grids, Vcl.ComCtrls;

type
  TfmRtvOrderBufferUpdate = class(TForm)
    TimerDisplay: TTimer;
    asgList: TStringGrid;
    edRowNo: TEdit;
    edRtvNo: TEdit;
    Label3: TLabel;
    Label5: TLabel;
    btnOrderUpdate2: TSpeedButton;
    cbPriority: TComboBox;
    cbStatus: TComboBox;
    Label110: TLabel;
    Label1: TLabel;
    edFromStation: TEdit;
    edToStation: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    edWorkNo: TEdit;
    cbOrderClass: TComboBox;
    Label17: TLabel;
    Label9: TLabel;
    Autocheck: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerDisplayTimer(Sender: TObject);
    procedure DisplayInfo();
    procedure btnOrderUpdate2Click(Sender: TObject);
    procedure asgListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure asgListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmRtvOrderBufferUpdate: TfmRtvOrderBufferUpdate;

  g_flr_no : Integer;

implementation

uses cs_rtv;

{$R *.dfm}
//------------------------------------------------------------------------------
// Form Create Event
//------------------------------------------------------------------------------
procedure TfmRtvOrderBufferUpdate.FormCreate(Sender: TObject);
begin
    asgList.RowCount := U_MAX_WORK+1;

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
procedure TfmRtvOrderBufferUpdate.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

//------------------------------------------------------------------------------
// Timer Event
//------------------------------------------------------------------------------
procedure TfmRtvOrderBufferUpdate.TimerDisplayTimer(Sender: TObject);
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

// -----------------------------------------------------------------------------

procedure TfmRtvOrderBufferUpdate.asgListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    leftPos, topPos : Integer;
    cellStr : String;
begin
    with asgList do
    if ARow > 0 then
    begin
        // RTV에 할당된 작업의 Row 색을 노란색으로 강조 표시
        if (asgList.Cells[9, ARow] <> '0') and (ACol < 12) then
            asgList.Canvas.Brush.Color := clYellow
        else
            asgList.Canvas.Brush.Color := clWindow;

        cellStr := TStringGrid(Sender).Cells[ACol, ARow];
        topPos := ((Rect.Top - Rect.Bottom - TStringGrid(Sender).Canvas.TextHeight(cellStr)) div 2) + Rect.Bottom;
        leftPos := ((Rect.Right - Rect.Left - TStringGrid(Sender).Canvas.TextWidth(cellStr)) div 2) + Rect.Left;

        // 배경 색과 텍스트를 설정된 대로 표시
        asgList.Canvas.FillRect(Rect);
        asgList.Canvas.TextOut(leftPos, topPos, cellStr);
    end;
    
end;

// -----------------------------------------------------------------------------

procedure TfmRtvOrderBufferUpdate.asgListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
    order_class, status : Integer;
begin
    asgList.Cells[1,  ARow];

    status := 0;
    order_class := 0;

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
procedure TfmRtvOrderBufferUpdate.btnOrderUpdate2Click(Sender: TObject);
var
    row_no : Integer;
begin
    row_no := StrToInt(edRowNo.Text);

    // Auto
    shmptr^.grp.rtvwork[row_no].workNo := StrToIntDef(edWorkNo.Text, 0);
    shmptr^.grp.rtvwork[row_no].orderClass := cbOrderClass.ItemIndex+1;
    shmptr^.grp.rtvwork[row_no].fromStation := StrToIntDef(edFromStation.Text, 0);
    shmptr^.grp.rtvwork[row_no].toStation := StrToIntDef(edToStation.Text, 0);
    shmptr^.grp.rtvwork[row_no].orderPriority := cbPriority.ItemIndex+1;
    shmptr^.grp.rtvwork[row_no].Status := cbStatus.ItemIndex;
    shmptr^.grp.rtvwork[row_no].rtvNo := StrToIntDef(edRtvNo.Text, 0);
end;

//------------------------------------------------------------------------------
procedure TfmRtvOrderBufferUpdate.DisplayInfo();
var
    idx_no : Integer;
    status, orderClass : String;
begin
    try
        for idx_no := 1 to U_MAX_WORK+1 do
        begin
            asgList.RowCount := U_MAX_WORK + 1;

            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_NONE then status := 'NONE';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_FRST then status := 'FRST';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_RESV then status := 'RESV';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_WAIT then status := 'WAIT';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_PEND then status := 'PEND';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_COMT then status := 'COMT';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_EXEC then status := 'EXEC';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_LOAD then status := 'LOAD';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_COMP then status := 'COMP';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_REST then status := 'REST';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_EROR then status := 'EROR';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_RTRY then status := 'RETY';
            if shmptr^.grp.rtvwork[idx_no].Status = U_COM_RECT then status := 'RECT';

            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_MOVE then orderClass := 'MOVE';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_LOAD then orderClass := 'LOAD';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_UNLD then orderClass := 'UNLD';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_TRAN then orderClass := 'TRAN';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_HOME then orderClass := 'HOME';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_ONLI then orderClass := 'ONLI';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_RSET then orderClass := 'RSET';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_STOP then orderClass := 'STOP';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_CLAR then orderClass := 'CLAR';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_MNDR then orderClass := 'MNDR';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_EMRY then orderClass := 'EMRY';
            if shmptr^.grp.rtvwork[idx_no].orderClass = U_RTV_FNC_CPRS then orderClass := 'CPRS';

            asgList.Cells[0,  idx_no] := IntToStr(idx_no);
            asgList.Cells[1,  idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].workNo);
            asgList.Cells[2,  idx_no] := orderclass;
            asgList.Cells[3,  idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].fromStation);
            asgList.Cells[4,  idx_no] := IntToStr(station_to_position(1, shmptr^.grp.rtvwork[idx_no].fromStation));
            asgList.Cells[5,  idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].toStation);
            asgList.Cells[6,  idx_no] := IntToStr(station_to_position(1, shmptr^.grp.rtvwork[idx_no].toStation));
            asgList.Cells[7,  idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].orderPriority);
            asgList.Cells[8,  idx_no] := status;
            asgList.Cells[9,  idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].rtvNo);
            asgList.Cells[10, idx_no] := IntToStr(shmptr^.grp.rtvwork[idx_no].passCount);
            asgList.Cells[11, idx_no] := DateTimeToStr(shmptr^.grp.rtvwork[idx_no].setTime);
        end;
    except on e: Exception do
        begin
            ShowMessage(e.Message);
        end;
    end;
end;

end.
