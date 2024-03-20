unit hmx.control;

interface

uses
  Windows, Classes, SysUtils, StdCtrls, IdBaseComponent, System.JSON,
  IdComponent, IdTCPConnection, IdTCPClient, IdAntiFreezeBase, IdAntiFreeze,
  GlobalVar, IniFiles, hmx.constant, hmx.define, HmxClass;

type
  THmxControl = class(THmxThread)
  private
    { Private declarations }
    FResult    : Boolean;
    FSleep     : Integer;
    FDisplay   : Boolean;
    FSSDisplay : Boolean;
    FSection   : String;
  protected
    procedure Execute; override;
  public
    constructor Create(Id : Integer; WHandle : HWND; WMessage : Integer;
                       MyIni : TiniFile; Section : String;  ShmInfo : Pointer); overload;

  end;

implementation

uses svcControl, GlobalFnc, ct_s010, ct_s020;

//------------------------------------------------------------------------------
// ���� ���� (���� ����)
//------------------------------------------------------------------------------
constructor THmxControl.Create(Id : Integer; WHandle : HWND; WMessage : Integer;
                                    MyIni : TiniFile; Section : String; ShmInfo : Pointer);
begin
    Inherited Create(True);
    FreeOnTerminate := True;

    Identifier := Id;
    LoopBeforeCount := 0;
    LoopCurrentCount := 0;
    WindowHandle := WHandle;
    WindowMessage := WMessage;

    FSection := Section;

    // Sleep �ð�
    FSleep := StrToIntDef(MyIni.ReadString(FSection, 'SLEEP', ''), 500);

    // �޽��� ȭ�� ǥ�� ���� (Y/N)
    FDisplay   := (MyIni.ReadString(FSection, 'DISPLAY', '') = 'Y');
    FSSDisplay := (MyIni.ReadString(FSection, 'STTN_DISPLAY', '') = 'Y');

    FResult := True;

    DisplayMessage('Thread Create Success!');
end;

//------------------------------------------------------------------------------
procedure THmxControl.Execute;
var
    grp_no, rtv_no, use_y : Integer;
begin
    // ��� ������ ������ ������ ����
    if FResult = False then Exit;

    gCtlPtr := @THmxThread(Self);

    gStartLog := THmxLog.Create(gPath, COM_LOG_PREFIX+'Start', 'Log', False, True);
    gStartLog.Add('Program Start');

    // ��¥ ���� ��ü ����
    gDayOfChange := THmxDayOfChange.Create;

    // �α� ���� ��ü ����
    gRemoveLogData := THmxRemoveLogData.Create(gPath, '-', faDirectory, gExpire);

    while not Terminated do
	begin
        // ������ ���� ī��Ʈ
        LoopCurrentCount := (LoopCurrentCount + 1) and $FFFF;

		Sleep(FSleep);

        //DisplayMessage('.');

        use_y := 0;

        for grp_no := 1 to U_MAX_GRP do
        begin
            //--------------------------------------------------------------
            // RTV SINGLE OR SYNCRO
            //--------------------------------------------------------------
            for rtv_no := 1 to U_MAX_RTV do
            begin
                if shmptr^.grp.rtvinfo[rtv_no].enable = True
                then use_y := use_y+1;
            end;

            if use_y >= 2
            then begin
                // Syncro RTV ����
                syncro_rtv_control(grp_no);
            end
            else if use_y = 1
            then begin
                { TODO : Loop RTV }
            end;

            // ��� ����
            update_rtv_status(grp_no);
        end;


        //------------------------------------------------------------------
        //
        // ��¥ ����� �α����� ����
        //------------------------------------------------------------------
        if gDayOfChange.Changed
        then gRemoveLogData.Execute;
	end;

    DisplayMessage('Thread Terminated....');
end;

end.



