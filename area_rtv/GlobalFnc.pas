unit GlobalFnc;

interface

uses SysUtils, ComCtrls, Classes, StdCtrls, HmxClass, IniFiles, Contnrs,
  hmx.constant, hmx.define;

procedure ctl_display(msg_ds : String); overload;

implementation

uses GlobalVar;

//------------------------------------------------------------------------------
// 메시지 출력
//------------------------------------------------------------------------------
procedure ctl_display(msg_ds : String); overload;
begin
    gCtlPtr.DisplayMessage(msg_ds);
end;


end.

