program p_cc_rtvcm;

uses
  Forms,
  Windows,
  Classes,
  SysUtils,
  MainForm in 'MainForm.pas' {fmMain},
  MainUnit in 'MainUnit.pas',
  GlobalVar in 'GlobalVar.pas',
  hmx.define in '..\..\incl\Define\hmx.define.pas',
  hmx.constant in '..\..\incl\Constant\hmx.constant.pas',
  HmxClass in '..\..\incl\HmxClass.pas',
  HmxFunc in '..\..\incl\HmxFunc.pas',
  helco.serial.tcp.server.mode_14byte in 'helco.serial.tcp.server.mode_14byte.pas',
  cs_rtv in '..\..\csub\cs_rtv.pas';

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
  Application.Run;

    ReleaseMutex(hMutex);
end.
