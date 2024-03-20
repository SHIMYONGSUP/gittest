{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

unit GlobalFnc;

interface

uses SysUtils, ComCtrls, Classes, StdCtrls, hmx.define, hmx.constant, HMxClass, IniFiles, Contnrs;

procedure DisplayMessage(const Value: String);

implementation

uses Windows, GlobalVar;

//------------------------------------------------------------------------------
// 2019.10.23 JSB 추가
// SendMessage -> PostMessage 방식으로 변경
//------------------------------------------------------------------------------
procedure DisplayMessage(const Value: String);
var
    DynVar : ^String;
begin
    if gWindowHandle <> 0
    then begin
        // 동적 변수 포인트 할당
        New(DynVar);

        // 동적 변수 데이터 할당
        DynVar^ := FormatDateTime('hh:nn:ss.zzz> ', Now) + Value;

        // 메시지 전송
        PostMessage(gWindowHandle, gWindowMessage, Integer(DynVar), gIdentifier);
    end;
end;


end.

