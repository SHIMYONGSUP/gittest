unit GlobalVar;

interface

uses ComCtrls, Classes, StdCtrls, HmxClass, IniFiles, Contnrs, hmx.constant,
     hmx.define, System.JSON;

const
   INI_CFG_FILE                     = U_SYS_ROOT + '\File\Config.INI';
   INI_CTL_FILE                     = U_SYS_ROOT + '\File\ControlRTV.INI';
   INI_SEC_DEVICE                   = 'DEVICE';
   INI_SEC_PREFIX                   = 'DEVICE_';

   INI_IDN_MAX_QTY                  = 'DEVICE_QTY';
   INI_IDN_DEV_CAPTION              = 'DEVICE_CAPTION';
   INI_IDN_WATCHDOG_INTERVAL        = 'WATCHDOG_INTERVAL';
   INI_IDN_HIDE_INTERVAL            = 'HIDE_INTERVAL';
   INI_IDN_CAPTION                  = 'CAPTION';
   INI_IDN_TYPE                     = 'TYPE';
   INI_IDN_SLEEP                    = 'SLEEP';
   INI_IDN_TIMEOUT                  = 'TIMEOUT';
   INI_IDN_PARAMETER                = 'PARAMETER';
   INI_IDN_DISPLAY                  = 'DISPLAY';

   INI_VAL_CONTROL                  = 'HMX.CONTROL';

   COM_LOG_PREFIX                   = 'ControlRTV_';

   U_START_REGS = 0;

type
    INI_INFO = record
        IniCaption   : TStringList;
        IniType      : TStringList;
        IniSleep     : TStringList;
        IniTimeOut   : TStringList;
        IniCommValue : TStringList;
        IniDisplay   : TStringList;
    end;

    INI_INFO_STC = record
        IniCaption    : TStringList;
        IniType       : TStringList;
        IniSleep      : TStringList;
        IniTimeOut    : TStringList;
        IniCommValue  : TStringList;
        IniStationQty : TStringList;
        IniForkQty    : TStringList;
        IniLogFile    : TStringList;
        IniDisplay    : TStringList;
        IniLanguege   : TStringList;
    end;

    station_record = record
        group_no     : Integer;
        station_no   : Integer;
        position     : Integer;
        station_type : String;
        priority     : Integer;
        possible     : String;
	end;
var
    gMaxDev                         : Integer;
    gCaption                        : String;
    gWatchdogInterval               : Integer;
    gHideInteval                    : Integer;
    gLanguge                        : String;
    gThreadRemaining                : Integer;
    gPath                           : String;
    gExpire                         : Integer;

    //----------------------[ Form Close 수동 해제 필요]------------------------
    gThread                         : array of THmxThread;
    gTabSheet                       : array of TTabSheet;
    gListBox                        : array of TListBox;
    gMsgList                        : array of THmxMsgList;
    gCommLog                        : array of THmxLog;
    gIniInfo                        : array of INI_INFO_STC;

    gThreadMsg                      : TStringList;

    gStartLog                       : THmxLog;
    gDayOfChange                    : THmxDayOfChange;
    gRemoveLogData                  : THmxRemoveLogData;
    gMyIni                          : TiniFile;
    gCtlPtr                         : ^THmxThread;

    // 제어에서 스테이션이 정의된 csv file을 읽어서 처리하기 위한 구조체와 변수
    gSttnInfo : array [1..U_MAX_GRP] of array of station_record;

    gSetMaxSttn : array [1..U_MAX_GRP] of Integer;
implementation

end.

