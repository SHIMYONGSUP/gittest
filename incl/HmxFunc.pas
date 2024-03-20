{*------------------------------------------------------*}
{*                         프로시저/함수 리스트         *}
{*-----------------------+------------------------------*}
{* 클래스                |  비고                        *}
{*-----------------------+------------------------------*}
{* CreateSharedMemory    | 공유메모리 생성              *}
{*-----------------------+------------------------------*}
{* GetSharedMemory       | 공유메모리 연결              *}
{*-----------------------+------------------------------*}
{* RemoveSharedMemory    | 공유메모리 제거              *}
{*-----------------------+------------------------------*}
{* GetFileVersion        | 실행중인 프로그램 버전 확인  *}
{*-----------------------+------------------------------*}
{* ReadIni               | INI 읽기                     *}
{*-----------------------+------------------------------*}
{* WriteIni              | INI 쓰기                     *}
{*-----------------------+------------------------------*}
{*                       |                              *}
{*-----------------------+------------------------------*}

unit HmxFunc;

interface

uses
  Windows, SysUtils, Forms, Dialogs, hmx.constant, hmx.define, IniFiles;

const
    //---- 패키지 함수명 정의
    GET_FILE_VERSION = '_GetFileVersion';
    READ_INI = '_ReadIni';
    WRITE_INI = '_WriteIni';

type
    //---- 패키지 함수 형태 선언
    TGetFileVersion = function(szFullPath: pChar): ShortString; stdcall;
    TReadIni = function(Section, Ident, FullPath: String): ShortString; stdcall;
    TWriteIni = function(Section, Ident, Write, FullPath: String): Boolean; stdcall;

    //---- 함수 선언
    function CreateSharedMemory(CreateShm: Boolean) : Boolean;
    function GetSharedMemory(CreateShm: Boolean) : Boolean;
    function RemoveSharedMemory(CreateShm: Boolean) : Boolean;

    function ReadIni(Section, Ident, FullPath: String): String;
    function WriteIni(Section, Ident, Write, FullPath: String): Boolean;
var
   hFile   : THandle;
   hMemMap : THandle;

implementation

//------------------------------------------------------------------------------
// 공유메모리 생성
//------------------------------------------------------------------------------
function CreateSharedMemory(CreateShm: Boolean) : Boolean;
var
    my_i : Integer;
    temp : array [0..sizeof(SHMEM_INFO)] of byte;
begin
    result := false;

    hFile := 0;
    if CreateShm
    then begin
        hFile := CreateFile(U_SYS_ROOT + '\File\Shmem.dat',
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
                                 U_SHM_MAP_FILE);

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
// 공유메모리 연결
//------------------------------------------------------------------------------
function GetSharedMemory(CreateShm: Boolean) : Boolean;
begin
    result := false;

    hFile := 0;
    if CreateShm
    then begin
        hFile := CreateFile(U_SYS_ROOT + '\File\Shmem.dat',
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
                                 U_SHM_MAP_FILE);

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
    if CreateShm
    then begin
        hFile := CreateFile(U_SYS_ROOT + '\File\Shmem.dat',
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
                                 U_SHM_MAP_FILE);

    if hMemMap = 0 then Exit;

    if not CloseHandle(hMemMap) then Exit;

    result := true;
end;


//------------------------------------------------------------------------------
// INI 읽기
//------------------------------------------------------------------------------
function ReadIni(Section, Ident, FullPath: String): String;
var
    iFile : Tinifile;
    strFilePath, iValue : string;
begin
    strFilePath := FullPath;

    if FileExists(strFilePath) then
    begin
      iValue := '';
      iFile := nil;
      try
          iFile := TiniFile.Create(strFilePath);
          iValue := iFile.ReadString(section, Ident, '');
      finally
          iFile.Free;
      end;
    end;
    result := iValue;
end;

//------------------------------------------------------------------------------
// INI 쓰기
//------------------------------------------------------------------------------
function WriteIni(Section, Ident, Write, FullPath: String): Boolean;
var
    iFile : Tinifile;
    strFilePath : string;
begin
    Result := False;

    strFilePath := FullPath;

    if FileExists(strFilePath) then
    begin
      iFile := nil;
      try
          iFile := TiniFile.Create(strFilePath);
          iFile.WriteString(section, Ident, write);
      finally
          iFile.Free;
          Result := True;
      end;
    end;
end;

end.
