unit RtvForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Grids,
   Buttons, ComCtrls, ExtCtrls, Dialogs, Menus;

type
  TfmRTV = class(TForm)
    TimerDisplay: TTimer;
    tcRtvNo: TTabControl;
    Label9: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    Label98: TLabel;
    Label111: TLabel;
    Label2: TLabel;
    Label40: TLabel;
    Label110: TLabel;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    btnReset: TButton;
    btnUpdate: TButton;
    edCurPos: TEdit;
    cbMode: TComboBox;
    cbCommStatus: TComboBox;
    cbError: TComboBox;
    cbExist: TComboBox;
    edSubErrcd: TEdit;
    edErrcd: TEdit;
    cbStatus: TComboBox;
    cbWorkType: TComboBox;
    Label3: TLabel;
    cbEnable: TComboBox;
    cbCompleteFlag: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerDisplayTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure asgListGetAlignment(Sender: TObject; ARow, ACol: Integer;
      var HAlign: TAlignment);
    procedure btnUpdateClick(Sender: TObject);
    procedure tcRtvNoChange(Sender: TObject);
    procedure tcRtvNoDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure tabFlrChange(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayInfo(rtv_no : Integer);
  public
    { Public declarations }
  end;

var
    g_flr_no : Integer;
implementation

uses hmx.constant, hmx.define;

{$R *.dfm}

//------------------------------------------------------------------------------
// Form Create Event
//------------------------------------------------------------------------------
procedure TfmRTV.FormCreate(Sender: TObject);
begin
    TimerDisplay.Enabled := True;
    g_flr_no := 1;
end;

//------------------------------------------------------------------------------
// Grid Alignment Event
//------------------------------------------------------------------------------
procedure TfmRTV.asgListGetAlignment(Sender: TObject; ARow,
  ACol: Integer; var HAlign: TAlignment);
begin
    HAlign := taCenter;
    //VAlign := vtaCenter;
end;

//------------------------------------------------------------------------------
// Form Close Event
//------------------------------------------------------------------------------
procedure TfmRTV.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

//------------------------------------------------------------------------------
// TabControl Change Event > Floor
//------------------------------------------------------------------------------
procedure TfmRTV.tcRtvNoChange(Sender: TObject);
var
    rtv_no : Integer;
begin
    rtv_no := tcRtvNo.TabIndex + 1;

    if rtv_no = 0 then Exit;

    // Info Display
    DisplayInfo(rtv_no);
end;

//------------------------------------------------------------------------------
// TabControl Change Event > RTV no
//------------------------------------------------------------------------------
procedure TfmRTV.tabFlrChange(Sender: TObject);
var
    rtv_cnt : TStringlist;
begin
    rtv_cnt := TStringlist.Create;

    if g_flr_no = 1
    then begin
        rtv_cnt.Add('RTV #1');
        rtv_cnt.Add('RTV #2');

        tcRtvNo.Tabs := rtv_cnt;
    end
    else if g_flr_no = 2
    then begin
        tcRtvNo.Tabs := rtv_cnt;
    end
    else begin
        rtv_cnt.Add('RTV #1');
        rtv_cnt.Add('RTV #2');

        tcRtvNo.Tabs := rtv_cnt;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmRTV.tcRtvNoDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
    with Control.Canvas do
    begin
        if Active
        then begin
            Brush.Color := clBlue;
            Rectangle(Rect);
            Font.Color := clWhite;
            TextOut(Rect.Left+4, Rect.Top+3,(Control as TTabControl).Tabs[TabIndex]);
        end
        else begin
            Brush.Color := clBtnFace;
            //Rectangle(Rect);
            Font.Color := clBtnText;
            TextOut(Rect.Left+4, Rect.Top+3,(Control as TTabControl).Tabs[TabIndex]);
        end;
    end;
end;

//------------------------------------------------------------------------------
// Timer Event
//------------------------------------------------------------------------------
procedure TfmRTV.TimerDisplayTimer(Sender: TObject);
var
    rtv_no : Integer;
begin
    rtv_no := tcRtvNo.TabIndex + 1;

    if rtv_no = 0 then exit;

    // Timer off
    TimerDisplay.Enabled := False;

    try
        // Auto Refresh Check
        if CheckBox1.Checked = False
        then begin
            edCurPos.Enabled       := true;
            cbMode.Enabled         := true;
            cbError.Enabled        := true;
            cbExist.Enabled        := true;
            cbEnable.Enabled       := true;
            cbCommStatus.Enabled   := true;
            cbStatus.Enabled       := true;
            cbWorkType.Enabled     := true;
            cbCompleteFlag.Enabled := true;
            edErrcd.Enabled        := true;
            edSubErrcd.Enabled     := true;
            btnUpdate.Enabled      := true;
            btnReset.Enabled       := true;
            Exit;
        end
        else begin
            edCurPos.Enabled       := false;
            cbMode.Enabled         := false;
            cbError.Enabled        := false;
            cbExist.Enabled        := false;
            cbEnable.Enabled       := false;
            cbCommStatus.Enabled   := false;
            cbStatus.Enabled       := false;
            cbWorkType.Enabled     := false;
            cbCompleteFlag.Enabled := false;
            edErrcd.Enabled        := false;
            edSubErrcd.Enabled     := false;
            btnUpdate.Enabled      := false;
            btnReset.Enabled       := false;
        end;

        // Info Display
        DisplayInfo(rtv_no);
    finally
        // Timer On
        TimerDisplay.Enabled := True;
    end;
end;

//------------------------------------------------------------------------------
// User Procedure
//------------------------------------------------------------------------------
procedure TfmRTV.DisplayInfo(rtv_no: Integer);
var
    enable, operationMode, status, error, exists, commstatus, completeFlag : Integer;
begin
    try
        if shmptr^.grp.rtvinfo[rtv_no].enable                    then enable := 0 else enable := 1;
        if shmptr^.grp.rtvinfo[rtv_no].operationMode             then operationMode := 1 else operationMode := 0;
        if shmptr^.grp.rtvinfo[rtv_no].status = U_RTV_STAT_REDY  then status := 0 else status := 1;
        if shmptr^.grp.rtvinfo[rtv_no].error                     then error := 1 else error := 0;
        if shmptr^.grp.rtvinfo[rtv_no].exists[1]                 then exists := 1 else exists := 0;
        if shmptr^.grp.rtvinfo[rtv_no].commStatus                then commstatus := 1 else commstatus := 0;
        if shmptr^.grp.rtvinfo[rtv_no].completeFlag              then completeFlag := 1 else completeFlag := 0;

        cbEnable.ItemIndex       := enable;
        cbMode.ItemIndex         := operationMode;
        cbStatus.ItemIndex       := status;
        cbError.ItemIndex        := error;
        cbExist.ItemIndex        := exists;
        cbCommStatus.ItemIndex   := commStatus;
        cbCompleteFlag.ItemIndex := completeFlag;

        cbWorkType.ItemIndex := shmptr^.grp.rtvinfo[rtv_no].workType;
        edCurPos.Text := IntToStr(shmptr^.grp.rtvinfo[rtv_no].currentPosition);
        cbCommStatus.ItemIndex := commStatus;
        edErrcd.Text := intToStr(shmptr^.grp.rtvinfo[rtv_no].errorCode);
        edSubErrcd.Text := intToStr(shmptr^.grp.rtvinfo[rtv_no].errorSubCode);

    except on e: Exception do
        begin
            ShowMessage(e.Message);
        end;
    end;
end;



//------------------------------------------------------------------------------
// Update Button Click Event
//------------------------------------------------------------------------------
procedure TfmRTV.btnUpdateClick(Sender: TObject);
var
    rtv_no : Integer;
begin
    // No Set
    rtv_no := tcRtvNo.TabIndex + 1;

    if rtv_no = 0 then Exit;

    if TSpeedButton(Sender).Name = 'btnUpdate'
    then begin
        shmptr^.grp.rtvinfo[rtv_no].currentPosition := StrToIntDef(edCurPos.Text, 0);
        shmptr^.grp.rtvinfo[rtv_no].operationMode := (cbMode.ItemIndex > 0);
        shmptr^.grp.rtvinfo[rtv_no].workType := cbWorkType.ItemIndex;
        shmptr^.grp.rtvinfo[rtv_no].error := cbError.ItemIndex > 0;
        shmptr^.grp.rtvinfo[rtv_no].exists[1] := cbExist.ItemIndex > 0;     // 1-bed
        shmptr^.grp.rtvinfo[rtv_no].enable := cbEnable.ItemIndex = 0;
        shmptr^.grp.rtvinfo[rtv_no].commStatus := cbCommStatus.ItemIndex > 0;
        shmptr^.grp.rtvinfo[rtv_no].status := cbStatus.ItemIndex+1;
        shmptr^.grp.rtvinfo[rtv_no].errorCode := StrToIntDef(edErrcd.Text,0);
        shmptr^.grp.rtvinfo[rtv_no].errorSubCode := StrToIntDef(edSubErrcd.Text,0);
        shmptr^.grp.rtvinfo[rtv_no].completeFlag := (cbCompleteFlag.ItemIndex > 0);
    end
    else
    if TSpeedButton(Sender).Name = 'btnReset'
    then begin
        shmptr^.grp.rtvinfo[rtv_no].currentPosition := 0;
        shmptr^.grp.rtvinfo[rtv_no].operationMode := False;
        shmptr^.grp.rtvinfo[rtv_no].workType := 0;
        shmptr^.grp.rtvinfo[rtv_no].error := False;
        shmptr^.grp.rtvinfo[rtv_no].exists[1] := False;     // 1-bed
        shmptr^.grp.rtvinfo[rtv_no].enable := False;
        shmptr^.grp.rtvinfo[rtv_no].commStatus := False;
        shmptr^.grp.rtvinfo[rtv_no].status := 0;
        shmptr^.grp.rtvinfo[rtv_no].errorCode := 0;
        shmptr^.grp.rtvinfo[rtv_no].errorSubCode := 0;
        shmptr^.grp.rtvinfo[rtv_no].completeFlag := False;
    end;
end;

end.
