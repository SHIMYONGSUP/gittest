{$WARN IMPLICIT_STRING_CAST_LOSS OFF}
{$WARN SYMBOL_DEPRECATED OFF}

unit svcControl;

interface

uses
    Windows, SysUtils, Classes, Dialogs, stdCtrls, extCtrls, Messages,
    Registry, WinSvc, PsAPI, WinSock, Tlhelp32, inifiles,  hmx.constant, hmx.define,
    System.UITypes;

const
	Service_KERNEL_DRIVER = $00000001;
	Service_FILE_SYSTEM_DRIVER = $00000002;
	Service_ADAPTER = $00000004;
	Service_RECOGNIZER_DRIVER = $00000008;

	Service_DRIVER = (	Service_KERNEL_DRIVER or
						Service_FILE_SYSTEM_DRIVER or
						Service_RECOGNIZER_DRIVER);

	Service_WIN32_OWN_PROCESS = $00000010;
	Service_WIN32_SHARE_PROCESS = $00000020;
	Service_WIN32 =	(	Service_WIN32_OWN_PROCESS or
						Service_WIN32_SHARE_PROCESS);

	Service_INTERACTIVE_PROCESS = $00000100;

	Service_TYPE_ALL = (Service_WIN32 or
						Service_ADAPTER or
						Service_DRIVER or
						Service_INTERACTIVE_PROCESS);
	//
	// assume that the total number of Services is less than 4096.
	// increase if necessary
	cnMaxServices = 1024;
	
type
    TOSVersion = (osUnknown, os95, os95OSR2, os98, os98SE, osNT3, osNT4, os2K, osME, osXP);
	TSvcA = array[0..cnMaxServices]	of PEnumServiceStatus;
    TListA = Array [0..1, 0..255] of String[63];
    TaPInAddr = array [0..10] of PInAddr;
    TipListA = array [0..7] of String[20];

	PSvcA = ^TSvcA;
    PListA = ^TListA;
    PTPanel = ^TPanel;
    PaPInAddr = ^TaPInAddr;
    PipListA = ^TipListA;

    function SearchString(List: TStrings; FindName: String): Integer;
    procedure ChangeButtonStatus(Button: PTPanel; Enabled: Boolean);

    function ServiceGetList(sMachine : string;
                            dwServiceType, dwServiceState : DWord;
                            myServicesList : PListA) : Integer;
    function ServiceGetStatus(sMachine, sService : String ) : String;
    function ServiceStart(sMachine, sService : string) : boolean;
    function ServiceStop(sMachine, sService : string) : boolean;

    function ProcessGetList(procList: PListA): Integer;
    function ProcessGetStatus(procList: TStrings; procName: String): String;
    procedure ProcessExecute(procName, dirName: String);
    procedure ProcessTerminate(pid : Integer);

    function RegistryGetItem(rootKey: HKEY; key: String; keyValue: String): String;
    function RegistryGetList(rootKey: HKEY; key: String; keyList: PListA): Integer;
    procedure RegistryInsert(rootKey: HKEY; key, keyName, keyValue: String);
    procedure RegistryUpdate(rootKey: HKEY; key, keyName, keyValue: String);
    procedure RegistryDelete(rootKey: HKEY; key, keyName: String);

    function SysGetLocalIP(ipList: PipListA): Integer;
    function SysGetComputerName(): string;
    function SysKillTask(name: string): integer;
    function SysGetLastErrorStr: string;
//    procedure DoShutdown(reboot: Boolean);
    function GetSystemOS: TOSVersion;

    function ReadIni(section, Ident, filename: String): string;
    function WriteIni(section, Ident, write, filename: String): Boolean;
    procedure RemoveDeadIcon;


implementation

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function SearchString(List: TStrings; FindName: String): Integer;
var
    my_i : integer;
begin
    result := 0;
    for my_i := 1 to List.Count-1 do
    begin
        if List[my_i] = FindName
        then begin
            result := my_i;
            break;
        end;
    end;
end;

//------------------------------------------------------------------------------
procedure ChangeButtonStatus(Button: PTPanel; Enabled: Boolean);
begin
    if Enabled
    then Button^.Color := $00C08080
    else Button^.Color := $00DEBCBC;

    Button^.Enabled := Enabled;
end;

//------------------------------------------------------------------------------
function ServiceGetList(sMachine: string;
                        dwServiceType, dwServiceState: DWord;
                        myServicesList: PListA): Integer;
var
	j : integer;// temp. use
	schm : SC_Handle;// Service control manager handle
	nBytesNeeded,// bytes needed for the next buffer, if any
	nServices,// number of Services
	nResumeHandle : DWord;// pointer to the next unread Service entry
	ssa : PSvcA;// Service status array
    errCode : DWord;
    errMesg : string;
begin
    Result := -1;

	// connect to the Service control manager
	schm := OpenSCManager(	PChar(sMachine), Nil, SC_MANAGER_ALL_ACCESS);

	// if successful...
	if(schm <= 0)
    then begin
        errCode := GetLastError;

        case errCode of
            ERROR_ACCESS_DENIED             : errMesg := 'The requested access was denied.';
            ERROR_DATABASE_DOES_NOT_EXIST   : errMesg := 'The specified database does not exist.';
            ERROR_INVALID_PARAMETER         : errMesg := 'A parameter that was specified is invalid.';
            else                              errMesg := 'Unknown error occured. Error = ' + IntToStr(errCode);
        end;

        MessageDlg(errMesg, mtError, [mbOK], 0);
        Exit;
     end;

     nResumeHandle := 0;

     New(ssa);

     EnumServicesStatus(	schm,
							dwServiceType,
							dwServiceState,
							ssa^[0],
							SizeOf(ssa^),
							nBytesNeeded,
							nServices,
							nResumeHandle );

     for j := 0 to nServices-1 do
     begin
		 myServicesList^[0, j] := StrPas(ssa^[j].lpServiceName);
		 myServicesList^[1, j] := StrPas(ssa^[j].lpDisplayName);
	 end;

	 Dispose(ssa);

	 // close Service control manager handle
	 CloseServiceHandle(schm);

    Result := nServices;
end;

//------------------------------------------------------------------------------
function ServiceGetStatus(sMachine, sService: String ): String;
var
	schm,                   // Service control manager handle
	schs : SC_Handle;       // Service handle
	ss : TServiceStatus;    // Service status
	dwStat : DWord;         // current Service status
begin
	dwStat := 0;

	// connect to the Service control manager
	schm := OpenSCManager(PChar(sMachine), Nil, SC_MANAGER_CONNECT);

	// if successful...
	if(schm > 0)then
	begin
		// open a handle to the specified Service
		schs := OpenService(schm,
							PChar(sService),
                            SERVICE_ALL_ACCESS);
//							Service_QUERY_STATUS);  // we want to query Service status

		// if successful...
		if(schs > 0)then
		begin
			// retrieve the current status of the specified Service
			if(QueryServiceStatus(schs,	ss))then
			begin
				dwStat := ss.dwCurrentState;
			end;
		end;

        // close Service handle
        CloseServiceHandle(schs);
	end;

    // close Service control manager handle
    CloseServiceHandle(schm);

    case dwStat of
        Service_STOPPED : Result := 'Stopped';
        Service_RUNNING : Result := 'Running';
        Service_PAUSED  : Result := 'Paused';
        else              Result := '';
    end;
end;

//------------------------------------------------------------------------------
function ServiceStart(sMachine, sService: string): boolean;
var
	schm,                   // Service control manager handle
	schs : SC_Handle;       // Service handle
	ss : TServiceStatus;    // Service status
	psTemp : PChar;         // temp char pointer
	dwChkP : DWord;         // check point
begin
	ss.dwCurrentState := 0;

	// connect to the Service control manager
	schm := OpenSCManager(	PChar(sMachine), Nil, SC_MANAGER_CONNECT);

	// if successful...
	if(schm > 0)then
	begin
		// open a handle to the specified Service
		schs := OpenService(schm,
							PChar(sService),
                            Service_START or        // we want to start the Service and
							Service_QUERY_STATUS);  // query service status

		// if successful...
		if(schs > 0)then
		begin
			psTemp := Nil;
			if(StartService(schs, 0, psTemp))
            then begin
				// check status
				if(QueryServiceStatus(schs,	ss))then
				begin
					while(Service_RUNNING <> ss.dwCurrentState)do
					begin
						//
						// dwCheckPoint contains a value that the Service
						// increments periodically to report its progress
						// during a lengthy operation.
						//
						// save current value
						//
						dwChkP := ss.dwCheckPoint;

						//
						// wait a bit before checking status again
						//
						// dwWaitHint is the estimated amount of time
						// the calling program should wait before calling
						// QueryServiceStatus() again
						//
						// idle events should be handled here...
						//
						Sleep(ss.dwWaitHint);

						if(not QueryServiceStatus(schs,	ss))then
						begin
							// couldn't check status break from the loop
							break;
						end;

						if(ss.dwCheckPoint < dwChkP)then
						begin
							// QueryServiceStatus didn't increment
							// dwCheckPoint as it should have.
							// avoid an infinite loop by breaking
							break;
						end;
					end;
				end;
			end;
		end;

        // close Service handle
        CloseServiceHandle(schs);
	end;

    // close Service control manager handle
    CloseServiceHandle(schm);

	// return TRUE if the Service status is running
	Result := Service_RUNNING =	ss.dwCurrentState;
end;

//------------------------------------------------------------------------------
function ServiceStop(sMachine, sService: string): boolean;
var
	schm,                   // Service control manager handle
	schs : SC_Handle;       // Service handle
	ss : TServiceStatus;    // Service status
	dwChkP : DWord;         // check point
begin
	ss.dwCurrentState := 0;

	// connect to the Service control manager
	schm := OpenSCManager(	PChar(sMachine), Nil, SC_MANAGER_CONNECT);

	// if successful...
	if(schm > 0)then
	begin
		// open a handle to the specified Service
		schs := OpenService(schm,
							PChar(sService),
                            Service_STOP or         // we want to stop the Service and
							Service_QUERY_STATUS);  // query service status

		// if successful...
		if(schs > 0)then
		begin
			if(ControlService(  schs, SERVICE_CONTROL_STOP, ss))
            then begin
                while(Service_STOPPED <> ss.dwCurrentState)do
                begin
				    //
					// dwCheckPoint contains a value that the Service
					// increments periodically to report its progress
					// during a lengthy operation.
					//
					// save current value
					//
					dwChkP := ss.dwCheckPoint;

					//
					// wait a bit before checking status again
					//
					// dwWaitHint is the estimated amount of time
					// the calling program should wait before calling
					// QueryServiceStatus() again
					//
					// idle events should be handled here...
					//
					Sleep(ss.dwWaitHint);

					if(not QueryServiceStatus(schs,	ss))then
					begin
						// couldn't check status break from the loop
						break;
					end;

					if(ss.dwCheckPoint < dwChkP)then
					begin
						// QueryServiceStatus didn't increment
						// dwCheckPoint as it should have.
						// avoid an infinite loop by breaking
						break;
					end;
				end;
			end
            else MessageDlg('서비스를 종료할 수 없습니다.', mtError, [mbOK], 0);
		end;

        // close Service handle
        CloseServiceHandle(schs);
	end;

    // close Service control manager handle
    CloseServiceHandle(schm);

	// return TRUE if the Service status is running
	Result := Service_RUNNING =	ss.dwCurrentState;
end;

//------------------------------------------------------------------------------
function ProcessGetList(procList: PListA): Integer;
var
    hProcess     : THandle;
    pdwProcessID : array [0..1024] of DWORD;
    pdwModule    : array[0..1024] of HINST;
    nI, nJ, rCount : integer;
    dwTemp       : DWORD;
    szModuleName : array[0..255] of char;
    myExt : string;
begin
    rCount := 0;
    
    ZeroMemory(@pdwProcessID, 1024*sizeof(DWORD));
    dwTemp := 0;
    if EnumProcesses(@pdwProcessID, 1024*sizeof(DWORD), dwTemp)
    then begin
        nI := 1; // pdwProcessID[0] : system idle process
        while pdwProcessID[nI] <> 0 do
        begin
            hProcess := OpenProcess(PROCESS_VM_READ or PROCESS_QUERY_INFORMATION,
                                    false,
                                    pdwProcessID[nI]);
            try
                if hProcess <> 0 then
                begin
                    ZeroMemory(@pdwModule, 1024*SizeOf(HINST));
                    if EnumProcessModules(hProcess, @pdwModule, 1024*SizeOf(HINST), dwTemp)
                    then begin
                        nJ := 0;
                        while pdwModule[nJ] <> 0 do
                        begin
                            GetModuleBaseName(hProcess, pdwModule[nJ], szModuleName, 256);
                            myExt := Copy(szModuleName, strlen(szModuleName)-2, 3);
                            if LowerCase(myExt) = 'exe'
                            then begin
                                procList^[0, rCount] := Copy(szModuleName, 1, strlen(szModuleName)+1);
                                procList^[1, rCount] := Format('%4d', [pdwProcessID[nI]]);
                                Inc(rCount);
                                break;
                            end;
                            
                            Inc(nJ);
                        end;
                    end;
                end;
            finally
                CloseHandle(hProcess);
                Inc(nI);
            end;
        end;
    end;
    				
    Result := rCount;
end;

//------------------------------------------------------------------------------
function ProcessGetStatus(procList: TStrings; procName: String): String;
var
    rCount : integer;
begin
	rCount := SearchString(procList, procName);
	
	case rCount of
		0  : Result := 'Dead';
		else Result := 'Alive';
	end;
end;

//------------------------------------------------------------------------------
procedure ProcessExecute(procName, dirName: String);
var
    StartUpInfo  : TStartUpInfo; // Win32의 STARTUPINFO 구조체
    ProcessInfo  : TProcessInformation; // Win32의 PROCESS_INFORMATION
    cShow        : word;
    fullname     : string;
begin
    cShow := 0;
    fullname := dirName + '\' + procName;

    { StartupInfo 구조체를 0으로 채운다. }
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    { StartupInfo 구조체에 적절한 값들을 넣는다. wShowWindow 필드에는
      SW_XXXX 상수를 넣는다. 이 필드에 어떤 값을 넣을 때에는 dwFlags 필드에
      STARTF_USESSHOWWINDOW 플래그를 설정해야 한다. TStartupInfo에 대한
      자세한 정보는 Win32 도움말의 STARTUPINFO 항목을 보기 바란다. }
    with StartupInfo do
    begin
        cb := SizeOf(TStartupInfo); // 구조체의 크기
        dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
        wShowWindow := cShow;
    end;

    CreateProcess(  nil,
                    PChar(fullname),
                    nil, nil,
                    False,
                    NORMAL_PRIORITY_CLASS,
                    nil,
                    PChar(dirName),
                    StartupInfo,
                    ProcessInfo);
end;

//------------------------------------------------------------------------------
procedure ProcessTerminate(pid : Integer);
var
    hProcess    : THandle;
begin
    hProcess := OpenProcess(PROCESS_TERMINATE,
                            false,
                            pid);

    TerminateProcess(hProcess, 0);
end;

//------------------------------------------------------------------------------
function RegistryGetItem(rootKey: HKEY; key: String; keyValue: String): String;
var
    Reg : TRegistry;
begin
    Reg := TRegistry.Create;

    Reg.RootKey := rootKey;
    Reg.CreateKey(key);
    Reg.OpenKey(key, False);

    Result := Reg.ReadString(keyValue);

    Reg.CloseKey;
    Reg.Free;
end;

//------------------------------------------------------------------------------
function RegistryGetList(rootKey: HKEY; key: String; keyList: PListA): Integer;
var
    Reg : TRegistry;
    wList : TStringList;
    my_i, rCount : Integer;
begin
    Reg := TRegistry.Create;
    wList := TStringList.Create;

    try
        Reg.RootKey := rootKey;
        Reg.CreateKey(key);
        Reg.OpenKey(key, False);

        Reg.GetValueNames(wList);
        rCount := wList.Count;

        if rCount > 0
        then begin
            for my_i := 0 to rCount-1 do
            begin
                keyList^[0, my_i] := wList[my_i];
                keyList^[1, my_i] := Reg.ReadString(wList[my_i]);
            end;
        end;
    finally
        Reg.CloseKey;
        wList.Free;
        Reg.Free;

    end;
    
    Result := rCount;
end;

//------------------------------------------------------------------------------
procedure RegistryInsert(rootKey: HKEY; key, keyName, keyValue: String);
var
    Reg : TRegistry;
begin
    Reg := TRegistry.Create;
    Reg.RootKey := rootKey;
    Reg.OpenKey(key, True);

    Reg.WriteString(keyName, keyValue);

    Reg.CloseKey;
    Reg.Free;
end;

//------------------------------------------------------------------------------
procedure RegistryUpdate(rootKey: HKEY; key, keyName, keyValue: String);
var
    Reg : TRegistry;
begin
    Reg := TRegistry.Create;
    Reg.RootKey := rootKey;
    Reg.OpenKey(key, True);

    Reg.WriteString(keyName, keyValue);

    Reg.CloseKey;
    Reg.Free;
end;

//------------------------------------------------------------------------------
procedure RegistryDelete(rootKey: HKEY; key, keyName: String);
var
    Reg : TRegistry;
begin
    Reg := TRegistry.Create;
    Reg.RootKey := rootKey;
    Reg.OpenKey(key, False);

    Reg.DeleteValue(keyName);

    Reg.CloseKey;
    Reg.Free;
end;

//------------------------------------------------------------------------------
function SysGetLocalIP(ipList: PipListA): Integer;
var  WSAData: TWSAData;
     phe: PHostEnt;
     pptr: PaPInAddr;
     hName: String[64];
     my_i: Integer;
begin
    my_i := 0;

    WSAStartup($101, WSAData);
    GetHostName(@hName, SizeOf(hName));
    phe := GetHostByName(@hName);

    if phe <> nil then begin
       pptr := PaPInAddr(Phe^.h_addr_list);
       for my_i := 0 to 7 do begin
           if pptr^[my_i] = nil then break;
           ipList^[my_i] := StrPas(inet_ntoa(pptr^[my_i]^));
       end;
    end;

    WSACleanUp();

    result := my_i;
end;

//------------------------------------------------------------------------------
function SysGetComputerName: string;
var
    buffer:  array[0..51] of Char;
    buflen:  dword;
begin
    buflen := 50;
    GetComputerName(buffer, buflen);
    result := Trim(StrPas(buffer));
end;

//------------------------------------------------------------------------------
function SysKillTask(name: string): integer;
var
    loop: BOOL;
    fsh: THandle;
    fpe: TProcessEntry32;
begin
  result := 0;

  fsh          := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  fpe.dwSize   := Sizeof(fpe);
  loop         := Process32First(fsh, fpe);

  while loop do begin
     if ((UpperCase(ExtractFileName(fpe.szExeFile)) = UpperCase(name))
     or  (UpperCase(fpe.szExeFile) = UpperCase(name))) then begin
        result := Integer(TerminateProcess(OpenProcess($0001, BOOL(0), fpe.th32ProcessID), 0));
     end;
     loop := Process32Next(fsh, fpe);
  end;

  CloseHandle(fsh);
end;

//------------------------------------------------------------------------------
function SysGetLastErrorStr: string;
var  buff : array[0..255] of char;
begin
  FillChar( buff, sizeof(buff), 0 );
  FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM,
                 nil, GetLastError, 0, buff, 255, nil );
  result := StrPas(buff);
end;

//------------------------------------------------------------------------------
{procedure DoShutdown(reboot: Boolean);
var
    rl,flags: Cardinal;
    hToken: Cardinal;
    tkp: TOKEN_PRIVILEGES;
begin
    flags := EWX_FORCE;
    if reboot
    then flags := flags or EWX_REBOOT
    else flags := flags or EWX_shutdown or EWX_POWEROFF;
//    flgs := (flgs and (not (EWX_REBOOT or EWX_shutdown or EWX_POWEROFF))) or EWX_LOGOFF;
    if Win32Platform = VER_PLATFORM_WIN32_NT
    then begin
        if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
        then MessageDlg('Cannot open process token.', mtError, [mbOk], 0)
        else begin
            if LookupPrivilegeValue(nil, 'SeshutdownPrivilege', tkp.Privileges[0].Luid)
            then begin
                tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
                tkp.PrivilegeCount := 1;
                AdjustTokenPrivileges(hToken, False, tkp, 0, nil, rl);
                if GetLastError <> ERROR_SUCCESS
                then MessageDlg('Error adjusting process privileges.', mtError, [mbOk], 0);
            end
            else MessageDlg('Cannot find privilege value.', mtError, [mbOk], 0);
        end;
    end;

    ExitWindowsEx(flags, 0);
end;  }

//------------------------------------------------------------------------------
function GetSystemOS: TOSVersion;
var
  OS :TOSVersionInfo;
begin
  ZeroMemory(@OS,SizeOf(OS));
  OS.dwOSVersionInfoSize:=SizeOf(OS);
  GetVersionEx(OS);
  Result:=osUnknown;
  if OS.dwPlatformId=VER_PLATFORM_WIN32_NT then begin
    case OS.dwMajorVersion of
      3: Result:=osNT3;
      4: Result:=osNT4;
      5: Result:=os2K;
    end;
    if (OS.dwMajorVersion=5) and (OS.dwMinorVersion=1) then
      Result:=osXP;
  end else begin
    if (OS.dwMajorVersion=4) and (OS.dwMinorVersion=0) then begin
      Result:=os95;
      if (Trim(OS.szCSDVersion)='B') then
        Result:=os95OSR2;
    end else
      if (OS.dwMajorVersion=4) and (OS.dwMinorVersion=10) then begin
        Result:=os98;
        if (Trim(OS.szCSDVersion)='A') then
          Result:=os98SE;
      end else
        if (OS.dwMajorVersion=4) and (OS.dwMinorVersion=90) then
          Result:=osME;
  end;
end;

//------------------------------------------------------------------------------
function ReadIni(section, Ident, filename: String): string;
var
    iFile : Tinifile;
    strFilePath, iValue : string;
begin
    strFilePath := filename;

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
function WriteIni(section, Ident, write, filename: String): Boolean;
var
    iFile : Tinifile;
    strFilePath : string;
begin
    Result := False;

    strFilePath := filename;

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

//------------------------------------------------------------------------------
procedure RemoveDeadIcon;
var
    wnd : cardinal;
    rec : TRect;
    w,h : integer;
    x,y : integer;
begin
    //find a handle of a tray
    wnd := FindWindow('Shell_TrayWnd', nil);
    wnd := FindWindowEx(wnd, 0, 'TrayNotifyWnd', nil);
    wnd := FindWindowEx(wnd, 0, 'SysPager', nil);
    wnd := FindWindowEx(wnd, 0, 'ToolbarWindow32', nil);
    // get client rectangle (needed for width and height of tray)
    windows.GetClientRect(wnd, rec);//(윈도우작업영역알아내기)GetClientRect(윈도우핸들, 작업영역좌표값)
    // get size of small icons
    w := GetSystemMetrics(sm_cxsmicon);//(윈도우화면크기알아내기)GetSystemMetrics(아이콘넓이)
    h := GetSystemMetrics(sm_cysmicon);//(윈도우화면크기알아내기)GetSystemMetrics(아이콘높이)
    // initial y position of mouse - half of height of icon
    y := w shr 1;

    while y < rec.Bottom do
    begin // while y < height of tray
        x := h shr 1; // initial x position of mouse - half of width of icon
        while x < rec.Right do
        begin // while x < width of tray
            SendMessage(wnd, wm_mousemove, 0, y shl 16 or x); // simulate moving mouse over an icon
            //x := x + w; // add width of icon to x position
            x := x + 2;
        end;
        y := y + h; // add height of icon to y position
    end;
end;

//------------------------------------------------------------------------------
end.
