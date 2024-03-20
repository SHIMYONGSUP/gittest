// 장비 수 정의
U_MAX_GRP           = 1;        // 자동창고 RTV GROUP 개수
U_MAX_PLC           = 6;        // PLC
U_MAX_CNV           = 999;      // CNV
U_MAX_STC           = 4;        // 스태커
U_MAX_RTV           = 2;        // RTV (1, 2호기)
U_MAX_SIT           = 2;        // 1:Front, 2:Rear
U_MAX_BCR           = 4;        // BCR
U_MAX_RFD           = 4;        // RFID
U_MAX_LGV           = 2;        // LGV
U_MAX_MLD           = 1;        // 미니로더
U_MAX_SHT           = 1;        // 셔틀

// STC 명령버퍼 정의
U_MAX_STC_REG        = 32;      // STC REGS
U_MAX_STC_STN        = 3;       // 1:1F, 2:2F, 3:5F
U_MAX_STC_FORK       = 1;
U_MAX_STC_ORDER      = 2;
U_MAX_STC_ORDER_TYPE = 3;       // 1:입고, 2:출고, 3:STATION TO STATION
U_MAX_STC_IN_STN     = 2;       // 스태커 MAX 입고 스테이션 (사용안함)
U_MAX_STC_OUT_STN    = 2;       // 스태커 MAX 출고 스테이션 (사용안함)

// RTV Define
U_MAX_RTV_REG       = 4;        // RTV REGS
U_MAX_RTV_STN       = 19;
U_MAX_RTV_LD_STN    = 9;        // MAX RTV Loading S/T Define
U_MAX_RTV_UD_STN    = 8;        // MAX RTV Unloading S/T Define
U_MAX_RTV_BED       = 1;
U_MAX_RTV_MANUAL    = 1;

// PLC Define
U_MAX_PLC_REG       = 90000;    // 최대 Read Register
U_MAX_PLC_STN       = 750;      // PLC 명령 버퍼 수량
U_MAX_PLC_OPP       = 100;      // O/p 수
U_MAX_PLC_ORDER     = 3;
U_MAX_PLC_SEND_LENGTH = 2;

// LGV Define
U_MAX_LGV_BED       = 1;
U_MAX_LGV_ORDER     = 2;
U_MAX_LGV_JOB       = 10;       // AGV 대수 + LOADING PORT 수

// BCR Define
U_MAX_BCR_LENGTH    = 50;

U_MAX_SHT_FORK      = 1;
U_MAX_SHT_LEVEL     = 8;

U_MAX_CNV_ORDER     = 2;
U_MAX_BCR_ORDER     = 2;
U_MAX_SEND_BUFFER   = 30;
U_MAX_ARV_CNT       = 10;

// WORK Define
U_MAX_FLR           = 1;        // 층
U_MAX_WORK          = 30;       // 작업개수
U_MAX_MOVE          = 1;        // 이동 작업개수
U_MAX_MANL          = 1;        // 수동 작업개수
U_RTV_BED_1         = 1;

// IF 통신상태 체크 리스트
U_MAX_IF_DEV        = 10;



