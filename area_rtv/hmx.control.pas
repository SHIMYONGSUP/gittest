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
// 공통 사항 (수정 금지)
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

    // Sleep 시간
    FSleep := StrToIntDef(MyIni.ReadString(FSection, 'SLEEP', ''), 500);

    // 메시지 화면 표시 유무 (Y/N)
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
    // 통신 설정값 오류시 쓰레드 종료
    if FResult = False then Exit;

    gCtlPtr := @THmxThread(Self);

    gStartLog := THmxLog.Create(gPath, COM_LOG_PREFIX+'Start', 'Log', False, True);
    gStartLog.Add('Program Start');

    // 날짜 변경 객체 생성
    gDayOfChange := THmxDayOfChange.Create;

    // 로그 삭제 객체 생성
    gRemoveLogData := THmxRemoveLogData.Create(gPath, '-', faDirectory, gExpire);

    while not Terminated do
	begin
        // 쓰레드 루프 카운트
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
                // Syncro RTV 로직
                syncro_rtv_control(grp_no);
            end
            else if use_y = 1
            then begin
                { TODO : Loop RTV }
            end;

            // 명령 상태
            update_rtv_status(grp_no);
        end;


        //------------------------------------------------------------------
        //
        // 날짜 변경시 로그파일 삭제
        //------------------------------------------------------------------
        if gDayOfChange.Changed
        then gRemoveLogData.Execute;
	end;

    DisplayMessage('Thread Terminated....');
end;

end.



