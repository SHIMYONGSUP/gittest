unit GlobalVar;

interface

uses Windows, ComCtrls, Classes, StdCtrls, hmx.define, hmx.constant, HmxClass,
     SyncObjs, IniFiles, Contnrs;

const
   INI_CFG_FILE                     = U_SYS_ROOT + '\File\Config.INI';
   INI_COM_FILE                     = U_SYS_ROOT + '\File\ComWSV.INI';
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
   INI_IDN_AUTO_SERVER_OPEN         = 'AUTO_SERVER_OPEN';

   INI_VAL_HMX_ETHERNET_IP          = 'HMX.ETHERNET.IP';
   INI_VAL_HMX_CONTROL              = 'HMX.CONTROL';

   COM_LOG_PREFIX                   = 'WSV_';

var
    gMaxDev                         : Integer;
    gCaption                        : String;
    gWatchdogInterval               : Integer;
    gHideInteval                    : Integer;
    gThreadRemaining                : Integer;
    gPath                           : String;
    gExpire                         : Integer;
    gAutoServerOpen                 : Boolean;

    //----------------------[ Form Close 수동 해제 필요]------------------------
    gThread                         : array of THmxThread;
    gTabSheet                       : array of TTabSheet;
    gListBox                        : array of TListBox;
    gMsgList                        : array of THmxMsgList;
    gCommLog                        : array of THmxLog;
    gStartLog                       : THmxLog;
    gDayOfChange                    : THmxDayOfChange;
    gRemoveLogData                  : THmxRemoveLogData;
    gEmsIniFile                     : TiniFile;
    gEmsKeyList                     : TStringList;
    gEmsStrList                     : TStringList;
    gMyIni                          : TiniFile;
    gMainPtr                        : ^THmxThread;
    gDebugPtr                       : ^THmxThread;
    gCtlPtr                         : ^THmxThread;
    gCriticalSection                : TCriticalSection;

    gMsg : String;
    gExit : Boolean;

    gIdentifier :  Integer;
    gLoopBeforeCount : Integer;
    gLoopCurrentCount : Integer;
    gReadBeforeCount : Integer;
    gReadCurrentCount : Integer;
    gReadTimeStamp : TDateTime;
    gSendTimeStamp : TDateTime;
    gWindowMessage : Integer;
    gWindowHandle : HWND;

implementation

end.

