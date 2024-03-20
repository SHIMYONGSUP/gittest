unit cs_misc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

var
   hFile   : THandle;
   hMemMap : THandle;

//function CreateSharedMemory(CreateShm: Boolean) : boolean;
//function GetSharedMemory(CreateShm: Boolean) : boolean;
//function RemoveSharedMemory(CreateShm: Boolean) : Boolean;
function cs_leftstr(mesg:String; len:integer) : String;
function cs_midstr(mesg:String; pos, len:integer) : String;
function cs_rightstr(mesg:String; len:integer) : String;
function cs_hextoint(buffer:String; digit:integer) : integer;
function cs_strtohex(buffer:String) : integer;
function cs_inttostr(number, digit:integer) : String;
function cs_strtoint(buffer:String) : Integer;
function cs_hextostr(number, digit:integer) : String;
function cs_caldate(value:integer; dashed:boolean) : String;
function cs_date(dashed:boolean) : String;
function cs_time(dashed:boolean) : String;
function cs_build_locn(row, bay, lev : Integer) : String;
function cs_trim_blank(srctxt: string): string;
procedure cs_devide_locn(locatn : String; var row, bay, lev : Integer);
//procedure cs_message(Messages: ShortString);




implementation

uses hmx.constant, hmx.define;

//------------------------------------------------------------------------------
//procedure cs_message(Messages: ShortString);
//var
//    msgbuf : String;
//begin
//    msgbuf := Format('%s: %s> %s', [ug_ProcName, ug_FuncName, Messages]);
//    OutputDebugString(PChar(msgbuf));
//end;

//------------------------------------------------------------------------------
//공유메모리 생성
//------------------------------------------------------------------------------
{function CreateSharedMemory(CreateShm: Boolean) : boolean;
var
    my_i : Integer;
    temp : array [0..sizeof(SHMEM_INFO)] of byte;
begin
    result := false;

    hFile := 0;
    if (GetSystemOS in [os95, os95OSR2, os98, os98SE, osME]) OR CreateShm
    then begin
        hFile := CreateFile('..\File\Shmem.dat',
                            GENERIC_READ or GENERIC_WRITE,
                            FILE_SHARE_READ OR FILE_SHARE_WRITE,
                            nil,
                            OPEN_ALWAYS,
                            FILE_ATTRIBUTE_HIDDEN, // OR FILE_FLAG_DELETE_ON_CLOSE,
                            0);

        if hFile = INVALID_HANDLE_VALUE then Exit;
    end;

    hMemMap := CreateFileMapping(hFile,
                                 nil,
                                 PAGE_READWRITE,
                                 0,
                                 sizeof(SHMEM_INFO),
                                 'FM_MemMap');

    if hMemMap = 0 then Exit;

    shmptr := MapViewOfFile(hMemMap,
                             FILE_MAP_ALL_ACCESS,
                             0,
                             0,
                             sizeof(SHMEM_INFO));

    if shmptr = nil then Exit;

    for my_i := 0 to sizeof(SHMEM_INFO) do temp[my_i] := 0;
    move(temp, shmptr^, sizeof(SHMEM_INFO));

    result := true;
end;

//------------------------------------------------------------------------------
// 공유메모리 읽어오기
//------------------------------------------------------------------------------
function GetSharedMemory(CreateShm: Boolean) : boolean;
begin
    result := false;

    hFile := 0;
    if (GetSystemOS in [os95, os95OSR2, os98, os98SE, osME]) OR CreateShm
    then begin
        hFile := CreateFile('..\File\Shmem.dat',
                            GENERIC_READ or GENERIC_WRITE,
                            FILE_SHARE_READ OR FILE_SHARE_WRITE,
                            nil,
                            OPEN_ALWAYS,
                            FILE_ATTRIBUTE_HIDDEN, // OR FILE_FLAG_DELETE_ON_CLOSE,
                            0);

        if hFile = INVALID_HANDLE_VALUE then Exit;
    end;

    hMemMap := CreateFileMapping(hFile,
                                 nil,
                                 PAGE_READWRITE,
                                 0,
                                 sizeof(SHMEM_INFO),
                                 'FM_MemMap');

    if hMemMap = 0 then Exit;

    shmptr := MapViewOfFile(hMemMap,
                             FILE_MAP_ALL_ACCESS,
                             0,
                             0,
                             sizeof(SHMEM_INFO));

    if shmptr = nil then Exit;

    result := true;
end;

//------------------------------------------------------------------------------
// 공유메모리 제거
//------------------------------------------------------------------------------
function RemoveSharedMemory(CreateShm: Boolean) : Boolean;
//var
//    ErrCod : Integer;
begin
    result := false;

    hFile := 0;
    if (GetSystemOS in [os95, os95OSR2, os98, os98SE, osME]) OR CreateShm
    then begin
        hFile := CreateFile('..\File\Shmem.dat',
                            GENERIC_READ or GENERIC_WRITE,
                            FILE_SHARE_READ OR FILE_SHARE_WRITE,
                            nil,
                            OPEN_ALWAYS,
                            FILE_ATTRIBUTE_HIDDEN, // OR FILE_FLAG_DELETE_ON_CLOSE,
                            0);

        if hFile = INVALID_HANDLE_VALUE then Exit;
    end;

    hMemMap := CreateFileMapping(hFile,
                                 nil,
                                 PAGE_READWRITE,
                                 0,
                                 sizeof(SHMEM_INFO),
                                 'FM_MemMap');

    if hMemMap = 0 then Exit;

    if not CloseHandle(hMemMap) then Exit;

    result := true;
end;
}
//------------------------------------------------------------------------------
function cs_leftstr(mesg:String; len:integer) : String;
var
    temp : String;
    my_i : integer;
begin
    temp := '';
    for my_i := 1 to len do temp := temp + mesg[my_i];

    result := temp;
end;

//------------------------------------------------------------------------------
function cs_rightstr(mesg:String; len:integer) : String;
var
    temp : String;
    my_i : integer;
    my_j : integer;
begin
    temp := '';
    my_j := length(mesg);
    for my_i := my_j-len+1 to my_j do temp := temp + mesg[my_i];

    result := temp;
end;

//------------------------------------------------------------------------------
function cs_midstr(mesg:String; pos, len:integer) : String;
var
    temp : String;
    my_i : integer;
begin
    temp := '';
    for my_i := 1 to len do
        temp := temp + mesg[pos+my_i-1];

    result := temp;
end;

//------------------------------------------------------------------------------
// 16진수를 10진수로 변환
//------------------------------------------------------------------------------
function cs_hextoint(buffer:String; digit:integer) : integer;
var
    my_num : integer;
    my_i   : integer;
begin
    my_num := 0;
    for my_i := 1 to digit do
    begin
        my_num := my_num shl 4;
        if (#47 < buffer[my_i]) and (buffer[my_i] < #58)
        then my_num := my_num + ord(buffer[my_i]) - 48
        else my_num := my_num + ord(buffer[my_i]) - 55;
    end;

    result := my_num;
end;

//------------------------------------------------------------------------------
// 문자열을 16진수로 변환
//------------------------------------------------------------------------------
function cs_strtohex(buffer:String) : integer;
var
    my_num : integer;
    my_i   : integer;
begin
    my_num := 0;
    for my_i := 1 to length(buffer) do
    begin
        my_num := my_num shl 4;
        if (#47 < buffer[my_i]) and (buffer[my_i] < #58)
        then my_num := my_num + ord(buffer[my_i]) - 48
        else my_num := my_num + ord(buffer[my_i]) - 55;
    end;

    result := my_num;
end;

//------------------------------------------------------------------------------
// 정수를 문자열로 변환
//------------------------------------------------------------------------------
function cs_inttostr(number, digit:integer) : String;
var
    buffer1, buffer2 : String;
    my_i, len        : integer;
begin
    buffer1 := inttostr(number);
    buffer2 := '';
    for my_i := 1 to digit
        do buffer2 := buffer2 + '0';

    len := length(buffer1);
    for my_i := 1 to len
        do buffer2[digit - len + my_i] := buffer1[my_i];

    result := buffer2;
end;

//------------------------------------------------------------------------------
// 문자열을 정수로 변환
//------------------------------------------------------------------------------
function cs_strtoint(buffer:String) : Integer;
begin
    if length(buffer) = 0
    then result := 0
    else result := StrToInt(buffer);
end;

//------------------------------------------------------------------------------
// 16진수를 문자열로 변환
//------------------------------------------------------------------------------
function cs_hextostr(number, digit:integer) : String;
var
    buffer : String;
    my_i    : integer;
begin
    buffer := inttohex(number, digit);
    for my_i := 1 to digit do
        if buffer[my_i] = ' ' then buffer[my_i] := '0';

    result := buffer;
end;

//------------------------------------------------------------------------------
// 날짜 계산
//------------------------------------------------------------------------------
function cs_caldate(value:integer; dashed:boolean) : String;
var
    cdate : TDateTime;
    buffer : String;
begin
    cdate := date + value;

    buffer := DateToStr(cdate);

    if dashed
    then result := buffer
    else result := cs_midstr(buffer, 1, 4)
                 + cs_midstr(buffer, 6, 2)
                 + cs_midstr(buffer, 9, 2);
end;

//------------------------------------------------------------------------------
//현재날짜 생성
//------------------------------------------------------------------------------
function cs_date(dashed:boolean) : String;
var
    tmpdat : String;
begin
    if dashed then                        // dashed는 날짜형 결정
        tmpdat := FormatDateTime('yyyy-mm-dd', now)
    else
        tmpdat := FormatDateTime('yyyymmdd', now);

    result := tmpdat;
end;

//------------------------------------------------------------------------------
// 현재시간 생성
//------------------------------------------------------------------------------
function cs_time(dashed:boolean) : String;
var
    tmptim : String;
begin
    if dashed then                            // dashed는 시간형 결정
        tmptim := FormatDateTime('hh:mm:ss', now)
    else
        tmptim := FormatDateTime('hhmmss', now);

    result := tmptim;
end;

//------------------------------------------------------------------------------
// locn 생성
//------------------------------------------------------------------------------
function cs_build_locn(row, bay, lev : Integer) : String;
begin
    result := cs_inttostr(row, 2) + cs_inttostr(bay, 2) + cs_inttostr(lev, 2);
end;

//------------------------------------------------------------------------------
// locn 결정
//------------------------------------------------------------------------------
procedure cs_devide_locn(locatn : String; var row, bay, lev : Integer);
begin
    row := StrToInt(cs_midstr(locatn, 1, 2));
    bay := StrToInt(cs_midstr(locatn, 3, 2));
    lev := StrToInt(cs_midstr(locatn, 5, 2));
end;

//------------------------------------------------------------------------------
function cs_trim_blank(srctxt: string): string;
var
    my_i, my_j : integer;
    buffer : array [1..255] of char;
begin
    my_j := 0;
    for my_i := 1 to length(srctxt) do
    begin
        if srctxt[my_i] = ' ' then continue;
        Inc(my_j);
        buffer[my_j] := srctxt[my_i];
    end;

    result := Copy(buffer, 1, my_j);
end;


end.

