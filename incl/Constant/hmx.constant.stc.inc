// 전후면 작업 관련 상수
U_STC_FR_FRONT     = 1;
U_STC_FR_REAR      = 2;

// 현대엘리베이터 스태커 관련 상수
U_STC_MDE_MANUAL   = 1;           // 수동 모드
U_STC_MDE_SEMI     = 2;           // 반자동 모드
U_STC_MDE_AUTO     = 3;           // 자동 모드
U_STC_MDE_REMOTE   = 4;           // 원격 모드

U_STC_STS_MANUAL   = 1;           // 수동 상태
U_STC_STS_READY    = 2;           // 대기 상태
U_STC_STS_WORKING  = 3;           // 작업중 상태
U_STC_STS_ERROR    = 4;           // 에러 상태

//U_STC_MSK_NONE = $00;      {* 0000 0000 *}
//U_STC_MSK_ONLI = $01;      {* 0000 0001 *}
//U_STC_MSK_BUSY = $01;      {* 0000 0001 *}
//U_STC_MSK_NBSY = $03;      {* 0000 0011 *}
//U_STC_MSK_CERR = $04;      {* 0000 0100 *}
//U_STC_MSK_HERR = $08;      {* 0000 1000 *}
//U_STC_MSK_EROR = $0C;      {* 0000 1100 *}
//U_STC_MSK_MASK = $0F;      {* 0000 1111 *}
//U_STC_MSK_HOME = $10;      {* 0001 0000 *}

U_STC_MSK_NONE = $00;          {* 0000 0000 *}
U_STC_MSK_ONLI = $01;          {* 0000 0001 *}
U_STC_MSK_BUSY = $01;          {* 0000 0001 *}
U_STC_MSK_NBSY = $03;          {* 0000 0011 *}
U_STC_MSK_CERR = $04;          {* 0000 0100 *}
U_STC_MSK_HERR = $08;          {* 0000 1000 *}
U_STC_MSK_EROR = $0C;          {* 0000 1100 *}
U_STC_MSK_MASK = $0F;          {* 0000 1111 *}
U_STC_MSK_HOME = $10;          {* 0001 0000 *}
U_STC_MSK_COMP = $E1;          {* 1110 0001 *}
U_STC_MSK_F1CP = $21;          {* 0010 0001 *}
U_STC_MSK_F2CP = $41;          {* 0100 0001 *}

                        {* FUNCTION ID DEFINITION OF STACKER *}
U_STC_FNC_NONE	= 0;		{*  No function occuring at now    	*}
U_STC_FNC_TERM	= 1;		{*  terminate communication        	*}
U_STC_FNC_OPEN	= 2;		{*  open communication             	*}
U_STC_FNC_SINQ	= 3;		{*  status inquiry                 	*}
U_STC_FNC_EINQ	= 4;		{*  error inquiry                  	*}
U_STC_FNC_MOVE	= 5;		{*  move command                   	*}
U_STC_FNC_STOR	= 6;		{*  store command                  	*}
U_STC_FNC_RTRV	= 7;		{*  retrieve command               	*}
U_STC_FNC_SHLF	= 8;		{*  shelf-to-shelf transfer commnad	*}
U_STC_FNC_STTN	= 9;		{*  station-to-station transfer cmd	*}
U_STC_FNC_DEST	= 10;		{*  destnation change command    	*}
U_STC_FNC_STRT	= 11;		{*  start command(MCR-1 direct)    	*}
U_STC_FNC_CLAR	= 12;		{*  clear command(MCR-1 direct)   	*}
U_STC_FNC_HOME	= 13;		{*  return to home(MCR-1 direct)   	*}
U_STC_FNC_RSET	= 14;		{*  reset command(MCR-1 direct)    	*}
U_STC_FNC_INIT	= 15;		{*  Initalize stacker to online    	*}
U_STC_FNC_TINQ	= 16;		{*  twin fork status inquiry       	*}
U_STC_FNC_CLR1	= 17;		{*  clear command (Fork #1)      	*}
U_STC_FNC_CLR2	= 18;		{*  clear command (Fork #2)      	*}
U_STC_FNC_DST2	= 19;		{*  destnation change command (ST)	*}
U_STC_FNC_HERT	= 20;		{*  S/C Heart Bit               	*}
U_STC_FNC_EMER	= 21;		{*  S/C Emergency               	*}
U_STC_FNC_CPRS	= 22;		{*  S/C complete reset             	*}
U_STC_FNC_CCTV	= 23;		{*  S/C CCTV MODE              	    *}

                        {* S/CRANE MESSAGE INFORMATION  *}
// S/Crane message information **************************/
U_MAX_SPOS  = 13;
U_STC_POS_FUNC	= 0;
U_STC_POS_FORK	= 1;		{* fork no.                     	*}
U_STC_POS_FSTN	= 2;		{* from station                 	*}
U_STC_POS_FROW	= 3;		{*      row                     	*}
U_STC_POS_FBAY	= 4;		{*      bay                     	*}
U_STC_POS_FLEV	= 5;		{*      lev                     	*}
U_STC_POS_FRCH	= 6;		{*      reach                   	*}
U_STC_POS_TSTN	= 7;		{* to   station                 	*}
U_STC_POS_TROW	= 8;		{*      row                     	*}
U_STC_POS_TBAY	= 9;		{*      bay                     	*}
U_STC_POS_TLEV	= 10;		{*      lev                     	*}
U_STC_POS_TRCH	= 11;		{*      reach                   	*}
U_STC_POS_STTN	= 12;		{*      tosttn                   	*}
U_STC_POS_HERT  = 13;       {*      HertBit                   	*}


// STC Status Array Index Define *********************/
U_STC_IDX_RSPCOD        = 1;        // 응답코드 00 정상
U_STC_IDX_STATUS        = 2;        // 크레인 상태(2byte)
U_STC_IDX_FORK_STAT     = 3;        // Fork 상태 (2byte)
U_STC_IDX_MAIN_ERR_CD   = 4;        // 메인 이상코드 (2byte)
U_STC_IDX_SUB_ERR_CD    = 5;        // Sub 이상코드 (2byte)
U_STC_IDX_F1_ERR_CD     = 6;        // Fork 1 이상코드
U_STC_IDX_F2_ERR_CD     = 7;        // Fork 2 이상코드
U_STC_IDX_ROW           = 8;        // 위치정보
U_STC_IDX_BAY           = 9;        // 위치정보
U_STC_IDX_LEV           = 10;       // 위치정보
U_STC_IDX_F1_DUPLICATE  = 11;       // Fork 1 이중입고
U_STC_IDX_F2_DUPLICATE  = 12;       // Fork 2 이중입고
U_STC_IDX_F1_EMPTY      = 13;       // Fork 1 공출고
U_STC_IDX_F2_EMPTY      = 14;       // Fork 2 공출고

U_STC_FORK_RUN_STATUS_STOP   = 1;   // FORK 멈춤 상태
U_STC_FORK_RUN_STATUS_F1_L_S = 2;   // FORK 왼쪽 HALF 정위치
U_STC_FORK_RUN_STATUS_F1_L_M = 3;   // FORK 왼쪽으로 이동 중
U_STC_FORK_RUN_STATUS_F1_C_S = 4;   // FORK 정위치
U_STC_FORK_RUN_STATUS_F1_R_M = 5;   // FORK 오른쪽으로 이동 중
U_STC_FORK_RUN_STATUS_F1_R_S = 6;   // FORK 오른쪽 HALF 정위치


// definition of PLC operation command
U_PLC_POS_WORK_NO1      = 1;         // WORK_NO1 (fork1)
U_PLC_POS_WORK_NO2      = 2;         // WORK_NO2 (fork2)
U_PLC_POS_ORDER_CLASS   = 3;         // ORDER_CLASS
U_PLC_POS_FROM_ST       = 4;         // FROM_ST (fork1)
U_PLC_POS_FROM_ROW      = 5;         // FROM_ROW (fork1)
U_PLC_POS_FROM_BAY      = 6;         // FROM_BAY (fork1)
U_PLC_POS_FROM_LEV      = 7;         // FROM_LEV (fork1)
U_PLC_POS_TO_ST         = 10;        // TO_ST (fork1)
U_PLC_POS_TO_ROW        = 11;        // TO_ROW (fork1)
U_PLC_POS_TO_BAY        = 12;        // TO_BAY (fork1)
U_PLC_POS_TO_LEV        = 13;        // TO_LEV (fork1)
U_PLC_POS_FROM_ST2      = 16;        // FROM_ST (fork2)
U_PLC_POS_FROM_ROW2     = 17;        // FROM_ROW (fork2)
U_PLC_POS_FROM_BAY2     = 18;        // FROM_BAY (fork2)
U_PLC_POS_FROM_LEV2     = 19;        // FROM_LEV (fork2)
U_PLC_POS_TO_ST2        = 22;        // TO_ST (fork2)
U_PLC_POS_TO_ROW2       = 23;        // TO_ROW (fork2)
U_PLC_POS_TO_BAY2       = 24;        // TO_BAY (fork2)
U_PLC_POS_TO_LEV2       = 25;        // TO_LEV (fork2)
U_PLC_POS_TO_MANUAL     = 27;        // 홈복귀, 이상리셋, 전체작업리셋 ...

// definition of PLC tracking area
U_PLC_WRT_STC_STAT = 51;         // PC Write 영역 (Exist, Status)
U_PLC_WRT_STC_EROR = 52;         // PC Write 영역 (Error code)
U_PLC_WRT_STC_ROW  = 55;         // PC Write 영역 (Current Row)
U_PLC_WRT_STC_BAY  = 56;         // PC Write 영역 (Current Bay)
U_PLC_WRT_STC_LEV  = 57;         // PLC Write 영역 (Current Level)
U_PLC_WRT_STC_FORK = 59;         // PLC Write 영역 (Fork)
U_PLC_WRT_STC_MOVE = 60;         // PLC Write 영역 (Move)
U_PLC_WRT_STC_MODE = 61;         // PLC Write 영역 (Mode)


