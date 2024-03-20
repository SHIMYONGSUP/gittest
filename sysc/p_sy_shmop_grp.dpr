program p_sy_shmop_grp;

uses
  Forms,
  Windows,
  Classes,
  SysUtils,
  MainForm in 'MainForm.pas' {fmMain},
  about in 'about.pas' {AboutBox},
  HmxFunc in '..\incl\HmxFunc.pas',
  MainUnit in 'MainUnit.pas',
  svcControl in '..\csub\svcControl.pas',
  cs_misc in '..\CSUB\cs_misc.pas',
  cs_init_st in '..\csub\cs_init_st.pas',
  HmxClass in '..\incl\HmxClass.pas',
  cs_mode in '..\csub\cs_mode.pas',
  hmx.constant in '..\incl\Constant\hmx.constant.pas',
  RtvForm in 'RtvForm.pas' {fmRTV},
  RtvOrderBufferUpdate in 'RtvOrderBufferUpdate.pas' {fmRtvOrderBufferUpdate},
  hmx.define in '..\incl\Define\hmx.define.pas',
  SimulationForm in 'SimulationForm.pas' {fmSimulation},
  RtvManualBufferUpdate in 'RtvManualBufferUpdate.pas' {fmRtvManualBufferUpdate},
  RtvMoveBufferUpdate in 'RtvMoveBufferUpdate.pas' {fmRtvMoveBufferUpdate},
  cs_rtv in '..\csub\cs_rtv.pas',
  GlobalVar in 'GlobalVar.pas';

{$R *.RES}

var
    hMutex : THandle;
    strbuf : TStringList;
    myproc : PWideChar;
begin
    strbuf := TStringList.Create;

    try
        strbuf.Text := StringReplace(Application.ExeName, '\', U_CTC_CR, [rfReplaceAll]);
        myproc := PWideChar(strbuf.Strings[strbuf.Count-1]);
    finally
        strbuf.Free;
    end;

    hMutex := OpenMutex(MUTEX_ALL_ACCESS, False, myproc);
    if hMutex <> 0
    then begin
        CloseHandle(hMutex);
        Exit;
    end;

    hMutex := CreateMutex(nil, False, myproc);

    Application.Initialize;
    Application.CreateForm(TfmMain, fmMain);
    Application.CreateForm(TAboutBox, AboutBox);
    Application.CreateForm(TfmRtvOrderBufferUpdate, fmRtvOrderBufferUpdate);
    Application.CreateForm(TfmRtvMoveBufferUpdate, fmRtvMoveBufferUpdate);
    //Application.CreateForm(TfmSimulation, fmSimulation);
    System.ReportMemoryLeaksOnShutdown := True;
    Application.Run;

    ReleaseMutex(hMutex);
end.
