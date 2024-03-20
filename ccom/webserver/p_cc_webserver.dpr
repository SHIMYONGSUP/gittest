program p_cc_webserver;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  MainForm in 'MainForm.pas' {fmMain},
  webserver in 'webserver.pas' {WebModule2: TWebModule},
  HmxClass in '..\..\incl\HmxClass.pas',
  HmxFunc in '..\..\incl\HmxFunc.pas',
  GlobalFnc in 'GlobalFnc.pas',
  GlobalVar in 'GlobalVar.pas',
  MainUnit in 'MainUnit.pas',
  hmx.constant in '..\..\incl\Constant\hmx.constant.pas',
  hmx.define in '..\..\incl\Define\hmx.define.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
