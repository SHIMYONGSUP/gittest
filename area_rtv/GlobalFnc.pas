unit GlobalFnc;

interface

uses SysUtils, ComCtrls, Classes, StdCtrls, HmxClass, IniFiles, Contnrs,
  hmx.constant, hmx.define;

procedure ctl_display(msg_ds : String); overload;

implementation

uses GlobalVar;

//------------------------------------------------------------------------------
// �޽��� ���
//------------------------------------------------------------------------------
procedure ctl_display(msg_ds : String); overload;
begin
    gCtlPtr.DisplayMessage(msg_ds);
end;


end.

