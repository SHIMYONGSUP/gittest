{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

unit GlobalFnc;

interface

uses SysUtils, ComCtrls, Classes, StdCtrls, hmx.define, hmx.constant, HMxClass, IniFiles, Contnrs;

procedure DisplayMessage(const Value: String);

implementation

uses Windows, GlobalVar;

//------------------------------------------------------------------------------
// 2019.10.23 JSB �߰�
// SendMessage -> PostMessage ������� ����
//------------------------------------------------------------------------------
procedure DisplayMessage(const Value: String);
var
    DynVar : ^String;
begin
    if gWindowHandle <> 0
    then begin
        // ���� ���� ����Ʈ �Ҵ�
        New(DynVar);

        // ���� ���� ������ �Ҵ�
        DynVar^ := FormatDateTime('hh:nn:ss.zzz> ', Now) + Value;

        // �޽��� ����
        PostMessage(gWindowHandle, gWindowMessage, Integer(DynVar), gIdentifier);
    end;
end;


end.

