// RTV 상태문의 데이터 시작 번지 정의
U_IDX_REG_START = 6;

// RTV 명령 버퍼 시작번지
U_IDX_FR_WRK_START1 = 10;
U_IDX_TO_WRK_START1 = 13;
U_IDX_FR_WRK_START2 = 16;
U_IDX_TO_WRK_START2 = 19;

// RTV 관련 정의
U_RTV_1 = 1;                // RTV1
U_RTV_2 = 2;                // RTV2
U_RTV_3 = 3;                // RTV3
U_RTV_4 = 4;                // RTV4
U_RTV_5 = 5;                // RTV5
U_RTV_6 = 6;                // RTV6
U_RTV_7 = 7;                // RTV7
U_RTV_8 = 8;                // RTV8
U_RTV_9 = 9;                // RTV9
U_RTV_10 = 10;              // RTV10

// definition of RTV operation command
U_TPOS_COMM  = 0;           {* RTV COMMAND : RTV 작업 *}
U_TPOS_ADDR  = 1;           {* 목적지 번지            *}


{* FUNCTION ID DEFINITION OF RTV *}
U_RTV_FNC_MOVE = 1;             // 이동
U_RTV_FNC_LOAD = 2;             // 적재
U_RTV_FNC_UNLD = 3;             // 이재
U_RTV_FNC_TRAN = 4;             // 운반
U_RTV_FNC_HOME = 5;             // 홈
U_RTV_FNC_ONLI = 6;             // 자동
U_RTV_FNC_RSET = 7;             // 리셋
U_RTV_FNC_STOP = 8;             // STOP/START
U_RTV_FNC_CLAR = 9;             // 작업삭제
U_RTV_FNC_MNDR = 10;            // 수동운전
U_RTV_FNC_EMRY = 11;            // 비상정지
U_RTV_FNC_CPRS = 12;            // 완료리셋

//********** RTV STATUS ARRAY INDEX DEFINE **********//
U_RTV_IDX_MODE = 1;             // 이상/정상, 수동, 자동, 대기
U_RTV_IDX_RNST = 2;             // 주행중, 정위치, 피딩중1, 화물적재1, 피딩중2, 화물적재2
U_RTV_IDX_WRNO = 3;             // 작업번호 1000의자리or 메인에러코드 십의자리
                                // 작업번호  100의자리or 메인에러코드 일의자리
                                // 작업번호   10의자리or 서브에러코드 십의자리
                                // 작업번호    1의자리or 서브에러코드 일의자리
U_RTV_IDX_DSTN = 7;             // 백의자리 (목적지 스테이션)
                                // 십의자리
                                // 일의자리
U_RTV_IDX_CSTN = 10;            // 백의자리 (현재위치 스테이션)
                                // 십의자리
                                // 일의자리
U_RTV_IDX_CPOS = 13;            // 천의자리 (현재위치 거리값 cm)
                                // 백의자리
                                // 십의자리
                                // 일의자리
U_RTV_IDX_SPED = 17;            // 백의자리 (주행속도)
                                // 십의자리
                                // 일의자리
U_RTV_IDX_ICTL = 20;            // 내부처리상태
U_RTV_IDX_IPOC = 21;            // 내부수행상태
U_RTV_IDX_OTDI = 22;            // 예비
U_RTV_IDX_CTDI = 23;            // 컨트롤러 DI
U_RTV_IDX_CTDO = 24;            // 컨트롤러 DO
U_RTV_IDX_CIO1 = 25;            // 통신IO
U_RTV_IDX_CIO2 = 26;            // 통신IO
U_RTV_IDX_SNI1 = 27;            // 인터록 센서 입력1
U_RTV_IDX_SNO1 = 28;            // 인터록 센서 출력1
U_RTV_IDX_SNI2 = 29;            // 인터록 센서 입력2
U_RTV_IDX_SNO2 = 30;            // 인터록 센서 출력2

// RTV 상태
U_RTV_STAT_REDY = 1;            // RTV 대기
U_RTV_STAT_WORK = 2;            // RTV 작업중

// RTV 주행상태
U_RTV_RUN_STAT_MOVE = 1;        // 주행중
U_RTV_RUN_STAT_STOP = 2;        // 정위치
U_RTV_RUN_STAT_ULOD = 3;        // 피딩중
U_RTV_RUN_STAT_LOAD = 4;        // 화물적재

//********** CE : RTV STATUS **********//


