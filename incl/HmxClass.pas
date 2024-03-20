{$WARN IMPLICIT_STRING_CAST_LOSS OFF}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN SUSPICIOUS_TYPECAST OFF}

unit HmxClass;

interface

uses
  SysUtils, StrUtils, StdCtrls, DB, Classes, Windows, XMLDoc, XMLIntf,
  Messages, Variants, Graphics, Controls, Forms, Vcl.Grids,
  Dialogs, xmldom, msxmldom, ComCtrls ;

const
    U_ONE_SECOND = 1 / (24 * 60 * 60);

type
  //----------------------------------------------------------------------------
  // 폴더 삭제 클래스
  //----------------------------------------------------------------------------
  THmxDayOfChange = class
  private
    FDay : TDateTime;
  public
    constructor Create;
    function Changed : Boolean;

  end;

  //----------------------------------------------------------------------------
  // 폴더 삭제 클래스
  //----------------------------------------------------------------------------
  THmxRemoveDir = class
  private
  public
    procedure RemoveDir(const APath: String);

  end;

  //----------------------------------------------------------------------------
  // Log Data 삭제 클래스
  //----------------------------------------------------------------------------
  THmxRemoveLogData = class(THmxRemoveDir)
  private
    FPath : String;
    FSeparate : String;
    FAttr : Integer;            // faAnyFile, faDirectory
    FExpire : Integer;

  public
    constructor Create(APath, ASeparate: String; AAttr, AExpire: Integer);
    procedure Execute;

  end;

  //----------------------------------------------------------------------------
  // Log Data 클래스
  //----------------------------------------------------------------------------
  THmxLog = class
  private
    FPath : String;
    FFile : String;
    FExtension : String;
    FDate : Boolean;
    FTime : Boolean;
    FFormat : String;
  public
    constructor Create(APath, AFile, AExtension: String; ADate, ATime: Boolean; AFormat: String = 'YYYY-MM-DD');
    procedure Add(const Value: String);
    procedure AddPerHour(const Value: String);
    procedure AddLog(const Value: String);

  end;

  //----------------------------------------------------------------------------
  // 통신 쓰레드 클래스
  //----------------------------------------------------------------------------
  THmxThread = class(TThread)
  private
    FIdentifier : Integer;
    FLoopBeforeCount : Integer;
    FLoopCurrentCount : Integer;
    FReadBeforeCount : Integer;
    FReadCurrentCount : Integer;
    FReadTimeStamp : TDateTime;
    FSendTimeStamp : TDateTime;
    FWindowMessage : Integer;
    FWindowHandle : HWND;
    procedure SetIdentifier(const Value: Integer);
    procedure SetLoopBeforeCount(const Value: Integer);
    procedure SetLoopCurrentCount(const Value: Integer);
    procedure SetReadBeforeCount(const Value: Integer);
    procedure SetReadCurrentCount(const Value: Integer);
    procedure SetReadTimeStamp(const Value: TDateTime);
    procedure SetSendTimeStamp(const Value: TDateTime);
    procedure SetWindowHandle(const Value: HWND);
    procedure SetWindowMessage(const Value: Integer);
  public
    Status : Integer;
    Restart : Boolean;
    ConnectString : array [1..10] of String;
    property Identifier : Integer read FIdentifier write SetIdentifier;
    property LoopBeforeCount : Integer read FLoopBeforeCount write SetLoopBeforeCount;
    property LoopCurrentCount : Integer read FLoopCurrentCount write SetLoopCurrentCount;
    property ReadBeforeCount : Integer read FReadBeforeCount write SetReadBeforeCount;
    property ReadCurrentCount : Integer read FReadCurrentCount write SetReadCurrentCount;
    property ReadTimeStamp : TDateTime read FReadTimeStamp write SetReadTimeStamp;
    property SendTimeStamp : TDateTime read FSendTimeStamp write SetSendTimeStamp;
    property WindowMessage : Integer read FWindowMessage write SetWindowMessage;
    property WindowHandle : HWND read FWindowHandle write SetWindowHandle;
    procedure DisplayMessage(const Value : String);
    procedure DisplaySendMessage(const Value : String);
  end;

  //----------------------------------------------------------------------------
  // 알람 타이머 클래스
  //----------------------------------------------------------------------------
  THmxAlarm = class
  private
    FAlarm : TDateTime;
    FInterval : Integer;
  public
    constructor Create(AInterval : Integer; StartBool : Boolean);
    function TimedOut : Boolean;
    procedure Reset;
  end;

  //----------------------------------------------------------------------------
  // ListBox 메세지 표시 클래스
  //----------------------------------------------------------------------------
  THmxMsgList = class
  private
    FListBox : TListBox;
    FCheckBox : TCheckBox;
    FLines : Integer;
  public
    constructor Create(AListBox : TListBox; ACheckBox : TCheckBox; ALines : Integer);
    procedure Add(AMesg : String);
  end;

  //----------------------------------------------------------------------------
  // Memo 메세지 표시 클래스
  //----------------------------------------------------------------------------
  THmxMsgMemo = class
  private
    FMemo : TMemo;
    FCheckBox : TCheckBox;
    FLines : Integer;
  public
    constructor Create(AMemo : TMemo; ACheckBox : TCheckBox; ALines : Integer);
    procedure Add(AMesg : String);
  end;

implementation

//------------------------------------------------------------------------------
// 알람 타이머 클래스
//------------------------------------------------------------------------------
constructor THmxAlarm.Create(AInterval : Integer; StartBool : Boolean);
begin
    inherited Create;

    if StartBool = False then FAlarm := 0
    else FAlarm := Now;

    FInterval := AInterval;
end;

//------------------------------------------------------------------------------
function THmxAlarm.TimedOut : Boolean;
begin
    Result := (Now - FAlarm) > (FInterval * U_ONE_SECOND);

    if Result = True then FAlarm := Now;
end;

//------------------------------------------------------------------------------
procedure THmxAlarm.Reset;
begin
    FAlarm := Now;
end;

//------------------------------------------------------------------------------
// ListBox 메세지 표시 클래스
//------------------------------------------------------------------------------
constructor THmxMsgList.Create(AListBox : TListBox; ACheckBox : TCheckBox; ALines : Integer);
begin
    inherited Create;

    FListBox := AListBox;
    FCheckBox := ACheckBox;
    FLines := ALines;
end;

//------------------------------------------------------------------------------
procedure THmxMsgList.Add(AMesg : String);
var
    lnLoop, lnCount : Integer;
begin
    if FCheckBox <> nil
    then if FCheckBox.Checked = False then exit;

    if FListBox = nil then Exit;

    lnCount := FListBox.Items.Count;

    for lnLoop := 0 to lnCount - FLines do
        FListBox.Items.Delete(0);

    FListBox.ItemIndex := FListBox.Items.Add(AMesg);
end;


//------------------------------------------------------------------------------
// Memo 메세지 표시 클래스
//------------------------------------------------------------------------------
constructor THmxMsgMemo.Create(AMemo : TMemo; ACheckBox : TCheckBox; ALines : Integer);
begin
    inherited Create;

    FMemo := AMemo;
    FCheckBox := ACheckBox;
    FLines := ALines;
end;

//------------------------------------------------------------------------------
procedure THmxMsgMemo.Add(AMesg : String);
var
    sPos : Integer;
begin
    if FCheckBox <> nil
    then if FCheckBox.Checked = False then exit;

    if FMemo = nil then Exit;

    FMemo.Lines.BeginUpdate;

    FMemo.Lines.Add(AMesg);

    SetLength(AMesg, 0);

    sPos := Length(FMemo.Lines.Text)
    - AnsiPos(FMemo.Lines.Strings[FMemo.Lines.Count - FLines], FMemo.Lines.Text) + 1;
    AMesg := AnsiRightStr(FMemo.Lines.Text, sPos);
    FMemo.Lines.Text := AMesg;

    FMemo.Lines.BeginUpdate;
end;


//------------------------------------------------------------------------------
// 2019.10.23 JSB 추가
// SendMessage -> PostMessage 방식으로 변경
//------------------------------------------------------------------------------
procedure THmxThread.DisplayMessage(const Value: String);
var
    DynVar : ^String;
begin
    if WindowHandle <> 0
    then begin
        // 동적 변수 포인트 할당
        New(DynVar);

        // 동적 변수 데이터 할당
        DynVar^ := FormatDateTime('hh:nn:ss.zzz> ', Now) + Value;

        // 메시지 전송
        SendMessage(WindowHandle, WindowMessage, Integer(DynVar), Identifier);
    end;
end;

//------------------------------------------------------------------------------
// 2019.10.23 JSB 변경
// 기존 DisplayMessage -> DisplaySendMessage 변경
//------------------------------------------------------------------------------
procedure THmxThread.DisplaySendMessage(const Value: String);
begin
    if WindowHandle <> 0
    then SendMessage(WindowHandle, WindowMessage, Integer(@Value), Identifier);
end;

procedure THmxThread.SetIdentifier(const Value: Integer);
begin
  FIdentifier := Value;
end;

procedure THmxThread.SetLoopBeforeCount(const Value: Integer);
begin
  FLoopBeforeCount := Value;
end;

procedure THmxThread.SetLoopCurrentCount(const Value: Integer);
begin
  FLoopCurrentCount := Value;
end;

procedure THmxThread.SetReadBeforeCount(const Value: Integer);
begin
  FReadBeforeCount := Value;
end;

procedure THmxThread.SetReadCurrentCount(const Value: Integer);
begin
  FReadCurrentCount := Value;
end;

procedure THmxThread.SetReadTimeStamp(const Value: TDateTime);
begin
  FReadTimeStamp := Value;
end;

procedure THmxThread.SetSendTimeStamp(const Value: TDateTime);
begin
  FSendTimeStamp := Value;
end;

procedure THmxThread.SetWindowHandle(const Value: HWND);
begin
  FWindowHandle := Value;
end;

procedure THmxThread.SetWindowMessage(const Value: Integer);
begin
  FWindowMessage := Value;
end;

{ THmxLog }

procedure THmxLog.Add(const Value: String);
var
    buffer : String;
    fp : TextFile;
begin
    // 경로가 없으면 로그 남기지 않는다.
    if FPath = '' then Exit;

    try
        {$I-}   // I/O Error 발생시 메시지 숨기기

        buffer := FPath + '\' + FormatDateTime(FFormat, Now);

        if not DirectoryExists(buffer)
        then ForceDirectories(buffer);  // 폴더 생성

        buffer := buffer + '\' + FFile + '.' + FExtension;

        if FileExists(buffer)
        then begin
            AssignFile(fp, buffer);
            Append(fp);
        end
        else begin
            AssignFile(fp, buffer);
            ReWrite(fp);
        end;

        if (FDate = True) and (FTime = True)
        then buffer := FormatDateTime('YYYY/MM/DD HH:MM:SS', Now) + '> ' + Value
        else
        if (FDate = True)
        then buffer := FormatDateTime('YYYY/MM/DD', Now) + '> ' + Value
        else
        if (FTime = True)
        then buffer := FormatDateTime('HH:MM:SS', Now) + '> ' + Value
        else buffer := Value;;

        WriteLn(fp, buffer);
    finally
        CloseFile(fp);

        {$I+}   // I/O Error 발생시 메시지 보이기
    end;
end;

procedure THmxLog.AddPerHour(const Value: String);
var
    buffer : String;
    fp : TextFile;
begin
    // 경로가 없으면 로그 남기지 않는다.
    if FPath = '' then Exit;

    try
        {$I-}   // I/O Error 발생시 메시지 숨기기

        buffer := FPath + '\' + FormatDateTime(FFormat, Now);

        if not DirectoryExists(buffer)
        then ForceDirectories(buffer);  // 폴더 생성

        buffer := buffer + '\' + FFile + '_' + FormatDateTime('HH', Now)  + '.' + FExtension;

        if FileExists(buffer)
        then begin
            AssignFile(fp, buffer);
            Append(fp);
        end
        else begin
            AssignFile(fp, buffer);
            ReWrite(fp);
        end;

        if (FDate = True) and (FTime = True)
        then buffer := FormatDateTime('YYYY/MM/DD HH:MM:SS', Now) + '> ' + Value
        else
        if (FDate = True)
        then buffer := FormatDateTime('YYYY/MM/DD', Now) + '> ' + Value
        else
        if (FTime = True)
        then buffer := FormatDateTime('HH:MM:SS', Now) + '> ' + Value
        else buffer := Value;

        WriteLn(fp, buffer);
    finally
        CloseFile(fp);

        {$I+}   // I/O Error 발생시 메시지 보이기
    end;
end;

procedure THmxLog.AddLog(const Value: String);
var
    buffer : String;
    fp : TextFile;
begin
    // 경로가 없으면 로그 남기지 않는다.
    if FPath = '' then Exit;

    try
        {$I-}   // I/O Error 발생시 메시지 숨기기

        buffer := FPath + '\';

        if not DirectoryExists(buffer)
        then ForceDirectories(buffer);  // 폴더 생성

        buffer := buffer + '\' + FFile + '.' + FExtension;

        if FileExists(buffer)
        then begin
            AssignFile(fp, buffer);
            Append(fp);
        end
        else begin
            AssignFile(fp, buffer);
            ReWrite(fp);
        end;

        if (FDate = True) and (FTime = True)
        then buffer := FormatDateTime('YYYY/MM/DD HH:MM:SS', Now) + '> ' + Value
        else
        if (FDate = True)
        then buffer := FormatDateTime('YYYY/MM/DD', Now) + '> ' + Value
        else
        if (FTime = True)
        then buffer := FormatDateTime('HH:MM:SS', Now) + '> ' + Value
        else buffer := Value;;

        WriteLn(fp, buffer);
    finally
        CloseFile(fp);

        {$I+}   // I/O Error 발생시 메시지 보이기
    end;
end;

constructor THmxLog.Create(APath, AFile, AExtension: String; ADate, ATime: Boolean; AFormat: String = 'YYYY-MM-DD');
begin
    FPath := APath;
    FFile := AFile;
    FDate := ADate;
    FTime := ATime;
    FExtension := AExtension;
    FFormat := AFormat;
end;

{ THmxRemoveDir }

procedure THmxRemoveDir.RemoveDir(const APath: String);
begin
    WinExec(PAnsiChar(AnsiString('cmd /c rmdir/s/q ' + APath)), SW_HIDE);
end;

{ THmxRemoveLogData }

constructor THmxRemoveLogData.Create(APath, ASeparate: String; AAttr, AExpire: Integer);
begin
    FPath := APath;
    FSeparate := ASeparate;
    FAttr := AAttr;
    FExpire := AExpire;
end;

procedure THmxRemoveLogData.Execute;
var
    sr: TSearchRec;
begin
    // 경로 정보가 없으면 무시
    if FPath = '' then Exit;

    // 기간 정보가 없으면 무시
    if FExpire <= 0 then Exit;

    // 루트에서는 삭제시 위험하므로 무시한다.
    if (UpperCase(FPath) = 'A:\') or
       (UpperCase(FPath) = 'B:\') or
       (UpperCase(FPath) = 'C:\') or
       (UpperCase(FPath) = 'D:\') or
       (UpperCase(FPath) = 'E:\') or
       (UpperCase(FPath) = 'F:\') or
       (UpperCase(FPath) = 'H:\') or
       (UpperCase(FPath) = 'I:\') or
       (UpperCase(FPath) = 'J:\') or
       (UpperCase(FPath) = 'K:\') or
       (UpperCase(FPath) = 'L:\') or
       (UpperCase(FPath) = 'M:\') or
       (UpperCase(FPath) = 'N:\') or
       (UpperCase(FPath) = 'O:\') or
       (UpperCase(FPath) = 'P:\') or
       (UpperCase(FPath) = 'Q:\') or
       (UpperCase(FPath) = 'R:\') or
       (UpperCase(FPath) = 'S:\') or
       (UpperCase(FPath) = 'T:\') or
       (UpperCase(FPath) = 'U:\') or
       (UpperCase(FPath) = 'V:\') or
       (UpperCase(FPath) = 'W:\') or
       (UpperCase(FPath) = 'X:\') or
       (UpperCase(FPath) = 'Y:\') or
       (UpperCase(FPath) = 'Z:\')
    then Exit;

    if SysUtils.FindFirst(FPath + '\*.*', FAttr, sr) = 0
    then begin
        repeat
            if SysUtils.FileDateToDateTime(sr.Time) < (Now - FExpire)
            then begin
                if (sr.Name = '.') or
                   (sr.Name = '..') or
                   (StrToIntDef(Copy(sr.Name, 1, 4), 0) < 2010) or
                   (StrToIntDef(Copy(sr.Name, 1, 4), 0) > 2999)
                then Continue;

                if (FSeparate <> '')
                then begin
                    if (Copy(sr.Name, 5, 1) <> FSeparate) or
                       (Copy(sr.Name, 8, 1) <> FSeparate) or
                       (StrToIntDef(Copy(sr.Name, 6, 2), 0) < 1) or
                       (StrToIntDef(Copy(sr.Name, 6, 2), 0) > 12) or
                       (StrToIntDef(Copy(sr.Name, 9, 2), 0) < 1) or
                       (StrToIntDef(Copy(sr.Name, 9, 2), 0) > 31)
                    then Continue;
                end
                else begin
                    if (StrToIntDef(Copy(sr.Name, 5, 2), 0) < 1) or
                       (StrToIntDef(Copy(sr.Name, 5, 2), 0) > 12) or
                       (StrToIntDef(Copy(sr.Name, 7, 2), 0) < 1) or
                       (StrToIntDef(Copy(sr.Name, 7, 2), 0) > 31)
                    then Continue;
                end;

                if (sr.Attr AND faDirectory) = faDirectory
                then RemoveDir(FPath + '\' + sr.Name)
                else SysUtils.DeleteFile(FPath + '\' + sr.Name);
            end;
        until SysUtils.FindNext(sr) <> 0;
    end;

    SysUtils.FindClose(sr);
end;

{ THmxDayOfChange }

constructor THmxDayOfChange.Create;
begin
    FDay := 0;
end;

function THmxDayOfChange.Changed: Boolean;
begin
    if (FDay <> Date)
    then begin
        FDay := Date;
        Result := True;
    end
    else Result := False;
end;






end.

