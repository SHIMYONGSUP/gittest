unit MainForm;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, System.JSON,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, ComCtrls,
  IdBaseComponent, IdComponent, IdTCPServer, IdSocketHandle, IdStack, IdContext,
  IdCustomTCPServer, IdGlobal, Data.DB, Data.Win.ADODB;

type
  TfmMain = class(TForm)
    MainMenu: TMainMenu;
    HelpAboutItem: TMenuItem;
    View1: TMenuItem;
    File1: TMenuItem;
    Exit1: TMenuItem;
    TrayIcon1: TTrayIcon;
    PopupMenu: TPopupMenu;
    N2: TMenuItem;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    Edit1: TMenuItem;
    IdTCPServer: TIdTCPServer;
    RTV1: TMenuItem;
    rtv_order: TMenuItem;
    StoredProc: TADOStoredProc;
    RTVOrder1: TMenuItem;
    Simulation: TMenuItem;
    RTVManual1: TMenuItem;
    RTVMove1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CreatChildForm(FormClass: TFormClass);
    function GetMDIForm(FormClass: TFormClass): TForm;
    procedure HelpAbout(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);

    procedure IdTCPServerConnect(AContext: TIdContext);
    procedure IdTCPServerDisconnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure RTV1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBox1Click(Sender: TObject);
    procedure RTVOrder1Click(Sender: TObject);
    procedure SimulationClick(Sender: TObject);
    procedure RTVManual1Click(Sender: TObject);
    procedure RTVMove1Click(Sender: TObject);
    //procedure SpErrMsgByException(Var proc: TADOStoredProc; E: Exception);

    private
    { Private declarations }
    public
    { Public declarations }
    fErrors : TStringList;
    fServerRunning : boolean;

  end;

var
  fmMain: TfmMain;
  gExit: Boolean = False;

implementation

uses MainUnit, about, hmx.define, hmx.constant, cs_init_st, cs_mode,
  svcControl, RtvForm, RtvOrderBufferUpdate, RtvMoveBufferUpdate, SimulationForm;

{$r *.dfm}

//------------------------------------------------------------------------------
procedure TfmMain.FormCreate(Sender: TObject);
begin
    try
        // �����޸� ����
        if CreateSHM <> 0
        then raise Exception.Create('GetSHM Fails!');

        fErrors := TStringList.Create;

    except on e: Exception do
        begin
            ShowMessage(e.Message);
            ExitProcess(0);
            Close;
        end;
    end;

    // �����̼� �� ��������
    if GetSttnInfo <> 0
    then raise Exception.Create('GetStationInfo Fails!');

end;
//------------------------------------------------------------------------------
procedure TfmMain.FormShow(Sender: TObject);
begin
    ShowWindow(Application.Handle,SW_SHOWNORMAL);
end;

//------------------------------------------------------------------------------
procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    fErrors.Free;
    Action := caFree;
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if gExit
    then CanClose := True
    else begin
        CanClose := False;
        ShowWindow(Application.Handle,SW_HIDE);
        Hide;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.CreatChildForm(FormClass: TFormClass);
begin
    if GetMDIForm(FormClass) = nil
    then FormClass.Create(Self)
    else begin
        GetMDIForm(FormClass).Show;
        GetMDIForm(FormClass).WindowState := wsNormal;
    end;
end;

//------------------------------------------------------------------------------
function TfmMain.GetMDIForm(FormClass: TFormClass): TForm;
var
    i : Integer;
begin
    Result := nil;

    for i := 0 to MDIChildCount - 1 do
    begin
        if MDIChildren[i].ClassType = FormClass
        then begin
            Result := MDIChildren[i];
            Break;
        end;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.CheckBox1Click(Sender: TObject);
begin
    if TCheckBox(Sender).Checked = True
    then begin
        TCheckBox(Sender).Font.Color := clBlack;
        TCheckBox(Sender).Color := clBtnFace;
    end
    else begin
        TCheckBox(Sender).Font.Color := clBlack;
        TCheckBox(Sender).Color := clSilver;
    end;
end;

//------------------------------------------------------------------------------
procedure TfmMain.RTV1Click(Sender: TObject);
begin
    CreatChildForm(TfmRTV);
end;

//------------------------------------------------------------------------------
procedure TfmMain.RTVManual1Click(Sender: TObject);
begin
    CreatChildForm(TfmRtvMoveBufferUpdate);
end;

//------------------------------------------------------------------------------
procedure TfmMain.RTVMove1Click(Sender: TObject);
begin
    CreatChildForm(TfmRtvMoveBufferUpdate);
end;

//------------------------------------------------------------------------------
procedure TfmMain.RTVOrder1Click(Sender: TObject);
begin
    CreatChildForm(TfmRtvOrderBufferUpdate);
end;

//------------------------------------------------------------------------------
procedure TfmMain.SimulationClick(Sender: TObject);
begin
    CreatChildForm(TfmSimulation);
end;

//------------------------------------------------------------------------------
procedure TfmMain.HelpAbout(Sender: TObject);
begin
    AboutBox.ShowModal;
end;

//------------------------------------------------------------------------------
procedure TfmMain.Exit1Click(Sender: TObject);
begin
    Close;
end;

//------------------------------------------------------------------------------
procedure TfmMain.TrayIcon1DblClick(Sender: TObject);
begin
    Show;
end;
//------------------------------------------------------------------------------
procedure TfmMain.N2Click(Sender: TObject);
begin
    gExit := True;
    Close;
end;

//------------------------------------------------------------------------------
procedure TfmMain.IdTCPServerConnect(AContext: TIdContext);
begin
    //lbProcesses.ItemIndex := lbProcesses.Items.Add('Connected IP: ' + AContext.Connection.Socket.Binding.PeerIP);
end;

//------------------------------------------------------------------------------
procedure TfmMain.IdTCPServerDisconnect(AContext: TIdContext);
begin
    //lbProcesses.ItemIndex := lbProcesses.Items.Add('Disconnect IP: ' + AContext.Connection.Socket.Binding.PeerIP);
end;

//------------------------------------------------------------------------------
procedure TfmMain.IdTCPServerExecute(AContext: TIdContext);
var
    equips, rcvbuf : String;
    rcvbyt, sndbyt : TidBytes;
begin
    // Sleep ������ CPU ����� ������������ �������� ���� �߻���
    sleep(10);

    // Inputbuffer�� �����Ͱ� ������ �ش� ���ν����� ���̻� �������� �ʴ´�.
    if AContext.Connection.Socket.InputBufferIsEmpty = True
    then exit;

    // In ������ �����͸� Bytes �� �д´�.
    AContext.Connection.Socket.ReadBytes(rcvbyt, AContext.Connection.Socket.InputBuffer.Size, False);

    // IdBytes -> String ����ȯ
    rcvbuf := BytesToString(rcvbyt);

    // Get Message Type
    equips := Copy(uppercase(rcvbuf), 1, 4);

    // SHMR �����޸� �䱸
    if equips = 'SHMR'
    then begin
        if Copy(uppercase(rcvbuf), 8, 3) = 'MON'
        then begin
            try
                // ������ �����޸𸮸� IdByte�� ��ȯ
                sndbyt := RawToBytes(shmptr^, SizeOf(shmptr^));

                //  �����޸� ����
                AContext.Connection.Socket.Write(sndbyt);
            except
            end;
        end;
    end;
end;

end.
