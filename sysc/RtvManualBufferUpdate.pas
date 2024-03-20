unit RtvManualBufferUpdate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls, System.UITypes,
  Vcl.Samples.Spin, hmx.define, hmx.constant, Vcl.Grids, Vcl.ComCtrls;

type
  TfmRtvManualBufferUpdate = class(TForm)
    TimerDisplay: TTimer;
    tabType: TTabControl;
    Panel3: TPanel;
    Autocheck: TCheckBox;
    asgList: TStringGrid;
    btnOrderUpdate2: TSpeedButton;
    Label3: TLabel;
    Label5: TLabel;
    Label110: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    Label17: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    edWorkNo: TEdit;
    cbOrderClass: TComboBox;
    edFromStation: TEdit;
    edToStation: TEdit;
    cbPriority: TComboBox;
    cbStatus: TComboBox;
    edRtvNo: TEdit;
    edRowNo: TEdit;
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
  fmRtvManualBufferUpdate: TfmRtvManualBufferUpdate;

  g_flr_no : Integer;

implementation

{$R *.dfm}
//------------------------------------------------------------------------------
// Form Create Event
//------------------------------------------------------------------------------
procedure TfmRtvManualBufferUpdate.FormCreate(Sender: TObject);
begin
    asgList.RowCount := U_MAX_RTV_MANUAL+1;

    asgList.Cells[1, 0] := 'Work No';
    asgList.Cells[2, 0] := 'Order Class';
    asgList.Cells[3, 0] := 'From';
    asgList.Cells[4, 0] := 'To';
    asgList.Cells[5, 0] := 'Priority';
    asgList.Cells[6, 0] := 'Status';
    asgList.Cells[7, 0] := 'Rtv No';
    asgList.Cells[8, 0] := 'PassCnt';
    asgList.Cells[9, 0] := 'Set Date';

    asgList.ColWidths[0] := 40;
    asgList.ColWidths[1] := 80;
    asgList.ColWidths[2] := 100;
    asgList.ColWidths[3] := 60;
    asgList.ColWidths[4] := 60;
    asgList.ColWidths[5] := 80;
    asgList.ColWidths[6] := 70;
    asgList.ColWidths[7] := 70;
    asgList.ColWidths[8] := 70;
    asgList.ColWidths[9] := 180;


    g_flr_no := 1;

    TimerDisplay.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TfmRtvManualBufferUpdate.tabTypeChange(Sender: TObject);
begin
   g_flr_no := tabType.TabIndex + 1;
   // Info Display
   DisplayInfo();
end;

//------------------------------------------------------------------------------
procedure TfmRtvManualBufferUpdate.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

//------------------------------------------------------------------------------
// Timer Event
//------------------------------------------------------------------------------
procedure TfmRtvManualBufferUpdate.TimerDisplayTimer(Sender: TObject);
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
procedure TfmRtvManualBufferUpdate.asgListSelectCell(Sender: TObject; ACol,
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
procedure TfmRtvManualBufferUpdate.btnOrderUpdate2Click(Sender: TObject);
var
    index : Integer;
begin
    index := tabType.TabIndex + 1;

    // Manual
    shmptr^.grp.rtvmaul[index].workNo := StrToIntDef(edWorkNo.Text, 0);
    shmptr^.grp.rtvmaul[index].orderClass := cbOrderClass.ItemIndex+1;
    shmptr^.grp.rtvmaul[index].fromStation := StrToIntDef(edFromStation.Text, 0);
    shmptr^.grp.rtvmaul[index].toStation := StrToIntDef(edToStation.Text, 0);
    shmptr^.grp.rtvmaul[index].orderPriority := cbPriority.ItemIndex+1;
    shmptr^.grp.rtvmaul[index].Status := cbStatus.ItemIndex;
    shmptr^.grp.rtvmaul[index].rtvNo := StrToIntDef(edRtvNo.Text, 0);
end;

//------------------------------------------------------------------------------
procedure TfmRtvManualBufferUpdate.DisplayInfo();
var
    idx_no, index : Integer;
    status, orderClass : String;
begin
    try
        for idx_no := 1 to U_MAX_RTV_MANUAL+1 do
        begin
            index := tabType.TabIndex;

            asgList.RowCount := 2;

            if shmptr^.grp.rtvmaul[index].Status = U_COM_NONE then status := 'NONE';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_FRST then status := 'FRST';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_RESV then status := 'RESV';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_WAIT then status := 'WAIT';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_PEND then status := 'PEND';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_COMT then status := 'COMT';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_EXEC then status := 'EXEC';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_LOAD then status := 'LOAD';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_COMP then status := 'COMP';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_REST then status := 'REST';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_EROR then status := 'EROR';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_RTRY then status := 'RETY';
            if shmptr^.grp.rtvmaul[index].Status = U_COM_RECT then status := 'RECT';

            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_MOVE then orderClass := 'MOVE';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_LOAD then orderClass := 'LOAD';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_UNLD then orderClass := 'UNLD';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_TRAN then orderClass := 'TRAN';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_HOME then orderClass := 'HOME';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_ONLI then orderClass := 'ONLI';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_RSET then orderClass := 'RSET';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_STOP then orderClass := 'STOP';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_CLAR then orderClass := 'CLAR';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_MNDR then orderClass := 'MNDR';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_EMRY then orderClass := 'EMRY';
            if shmptr^.grp.rtvmaul[index].orderClass = U_RTV_FNC_CPRS then orderClass := 'CPRS';

            asgList.Cells[0,  1] := IntToStr(idx_no-1);
            asgList.Cells[1,  1] := IntToStr(shmptr^.grp.rtvmaul[index].workNo);
            asgList.Cells[2,  1] := orderClass;
            asgList.Cells[3,  1] := IntToStr(shmptr^.grp.rtvmaul[index].fromStation);
            asgList.Cells[4,  1] := IntToStr(shmptr^.grp.rtvmaul[index].toStation);
            asgList.Cells[5,  1] := IntToStr(shmptr^.grp.rtvmaul[index].orderPriority);
            asgList.Cells[6,  1] := status;
            asgList.Cells[7,  1] := IntToStr(shmptr^.grp.rtvmaul[index].rtvNo);
        end;
    except on e: Exception do
        begin
            ShowMessage(e.Message);
        end;
    end;

end;
end.
