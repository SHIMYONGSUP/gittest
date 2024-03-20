program p_ar_ctrls_rtv;

uses
  Forms,
  Windows,
  Classes,
  SysUtils,
  MainForm in 'MainForm.pas' {fmMain},
  hmx.control in 'hmx.control.pas',
  svcControl in '..\csub\svcControl.pas',
  HmxClass in '..\incl\HmxClass.pas',
  MainUnit in 'MainUnit.pas',
  cs_misc in '..\csub\cs_misc.pas',
  GlobalFnc in 'GlobalFnc.pas',
  GlobalVar in 'GlobalVar.pas',
  hmx.constant in '..\incl\Constant\hmx.constant.pas',
  hmx.define in '..\incl\Define\hmx.define.pas',
  HmxFunc in '..\incl\HmxFunc.pas',
  ct_s010 in 'ct_s010.pas',
  ct_s020 in 'ct_s020.pas',
  cs_rtv in '..\csub\cs_rtv.pas';

{$R *.RES}

var
    hMutex : THandle;
    strbuf : TStringList;
    myproc : PWideChar;
begin
    // strbuf √ ±‚»≠
    strbuf := nil;

    try
        strbuf := TStringList.Create;
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
  System.ReportMemoryLeaksOnShutdown := True;
    Application.Run;

    ReleaseMutex(hMutex);
end.
