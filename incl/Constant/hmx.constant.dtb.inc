// 작업 구분
U_DTB_WRK_CLS_STORE_IN          = '1';                  // 입고 작업
U_DTB_WRK_CLS_STORE_OUT         = '2';                  // 출고 작업
U_DTB_WRK_CLS_DELIVER           = '3';                  // 이동 작업
U_DTB_WRK_CLS_RACK_MOVE         = '4';                  // 랙이동 작업
U_DTB_WRK_CLS_DIRECT_OUT        = '6';                  // 직출고 작업

// 작업 유형
U_DTB_WRK_TYP_IN                = '1';
U_DTB_WRK_TYP_OUT               = '2';
U_DTB_WRK_TYP_RE_IN             = '3';
U_DTB_WRK_TYP_RACK_MOVE         = '4';
U_DTB_WRK_TYP_MOVE              = '5';
U_DTB_WRK_TYP_PLT_IN            = '6';
U_DTB_WRK_TYP_PLT_OUT           = '7';
U_DTB_WRK_TYP_CONFIRM_OUT       = '8';
U_DTB_WRK_TYP_VIRTUAL_IN        = '9';
U_DTB_WRK_TYP_VIRTUAL_OUT       = '10';
U_DTB_WRK_TYP_PICKING           = '11';

// 실행 구분
U_DTB_EXE_CLS_AUTO              = 1;                  // 자동작업
U_DTB_EXE_CLS_MANUAL            = 2;                  // 수동작업
U_DTB_EXE_CLS_RESET             = 3;

// 작업 상태
U_DTB_WS_RESERVE                = '1';
U_DTB_WS_WAIT                   = '2';
U_DTB_WS_WORKING                = '3';
U_DTB_WS_ERROR                  = '4';
U_DTB_WS_CANCEL                 = '5';
U_DTB_WS_COMPLETE               = '6';
U_DTB_WS_CANNOT_CANCEL          = '7';

// 작업 상태 Detail
U_DTB_WRK_STS_NONE              = 0;                    // 작업없음
U_DTB_WRK_STS_RESERVE           = 1;                    // 작업예약

U_DTB_WRK_STS_STC_WAIT          = 12;                   // 스태커크레인 작업대기
U_DTB_WRK_STS_STC_SEND_ORDER    = 13;                   // 오더전송
U_DTB_WRK_STS_STC_WORK          = 14;                   // 스태커크레인 작업중
U_DTB_WRK_STS_STC_COMP          = 15;                   // 스태커크레인 완료

U_DTB_WRK_STS_CNV_WAIT          = 22;                   // 컨베어 작업대기
U_DTB_WRK_STS_CNV_SEND_ORDER    = 23;                   // 오더전송
U_DTB_WRK_STS_CNV_WORK          = 24;                   // 컨베어 작업중
U_DTB_WRK_STS_CNV_COMP          = 25;                   // 컨베어 완료

U_DTB_WRK_STS_RTV_WAIT          = 32;                   // RTV 작업대기
U_DTB_WRK_STS_RTV_SEND_ORDER    = 33;                   // 오더전송
U_DTB_WRK_STS_RTV_WORK          = 34;                   // RTV 작업중
U_DTB_WRK_STS_RTV_COMP          = 35;                   // RTV 완료

U_DTB_WRK_STS_LGV_WAIT          = 42;                   // LGV 작업대기
U_DTB_WRK_STS_LGV_SEND_ORDER    = 43;                   // 오더전송
U_DTB_WRK_STS_LGV_WORK          = 44;                   // LGV 작업중
U_DTB_WRK_STS_LGV_COMP          = 45;                   // LGV 완료

U_DTB_WRK_STS_EMS_WAIT          = 52;                   // LGV 작업대기
U_DTB_WRK_STS_EMS_SEND_ORDER    = 53;                   // 오더전송
U_DTB_WRK_STS_EMS_WORK          = 54;                   // LGV 작업중
U_DTB_WRK_STS_EMS_COMP          = 55;                   // LGV 완료

U_DTB_WRK_STS_ERROR             = 6;                    // 이상
U_DTB_WRK_STS_CANCEL            = 7;                    // 작업취소
U_DTB_WRK_STS_CANNOT_CANCEL     = 8;                    // 취소불가
U_DTB_WRK_STS_COMPLETE          = 9;                    // 작업완료

// 보관 상태
U_DTB_STG_STS_NORMAL            = '1';                  // 정상
U_DTB_STG_STS_STORE_IN          = '2';                  // 입고중
U_DTB_STG_STS_STORE_OUT         = '3';                  // 출고중
U_DTB_STG_STS_CONFIRM           = '4';                  // 확인
U_DTB_STG_STS_EMPTY             = '5';                  // 공출고
U_DTB_STG_STS_DUPLICATE         = '6';                  // 이중입고
U_DTB_STG_STS_REPAIR            = '7';                  // 수리

// 사용 허가
U_DTB_STG_USE_Y                 = '1';                  // 사용가능 (정상 렉)
U_DTB_STG_USE_N                 = '2';                  // 사용불가 (금지 렉)

// 설비 구분
U_DTB_EQM_CLS_RACK              = 1;                  // 창고 렉
U_DTB_EQM_CLS_YARD              = 2;                  // 평치
U_DTB_EQM_CLS_CNV               = 3;                  // 컨베어
U_DTB_EQM_CLS_STC               = 4;                  // 스태커크레인
U_DTB_EQM_CLS_MLD               = 5;                  // 미니로더
U_DTB_EQM_CLS_RTV               = 6;                  // RTV
U_DTB_EQM_CLS_SORT              = 7;                  // 소터
U_DTB_EQM_CLS_CHUTE             = 8;                  // 슈트
U_DTB_EQM_CLS_PC                = 9;                  // PC


// 설비 메이커 버전
U_DTB_EQM_MKR_VER_CNV           = 'MITSUBISHI.3.01';
U_DTB_EQM_MKR_VER_STC           = 'Hyundai.4.01';
U_DTB_EQM_MKR_VER_MLD           = 'Hyundai.5.01';
U_DTB_EQM_MKR_VER_RTV           = 'Hyundai.6.40';

// 장소 코드
U_DTB_SITE_CD_FROZEN            = '1';                  // 팔레트창고(냉동)
U_DTB_SITE_CD_COLD              = '2';                  // 팔레트창고(냉장)
U_DTB_SITE_CD_BOX               = '3';                  // 박스창고
U_DTB_SITE_CD_MSTORAGE          = '4';                  // 수동창고
U_DTB_SITE_CD_INBOUND           = '5';                  // 입고장
U_DTB_SITE_CD_OUTBOUND          = '6';                  // 출고장
U_DTB_SITE_CD_SHIP              = '7';                  // 출하장

// FLOOR 구분
U_DTB_FLR_CLS_1ST               = '1';                  // 1층
U_DTB_FLR_CLS_2ND               = '2';                  // 2층
U_DTB_FLR_CLS_3RD               = '3';                  // 3층

// 높이 구분 코드
U_DTB_HGH_CLS_LOW               = '0';                  // 낮음
U_DTB_HGH_CLS_HIGH              = '1';                  // 높음

// 적재 구분
U_DTB_LOD_CLS_PALLET            = 'P';                  // 팔레트
U_DTB_LOD_CLS_BOX               = 'B';                  // 박스

// 데이터베이스 접속상태 배열 첨자
U_DTB_CNC_CTL                   = 1;
U_DTB_CNC_PDA                   = 2;
U_DTB_CNC_ERP                   = 3;
U_DTB_CNC_MES                   = 4;


// 컨베어 에러코드 정의.
U_DTB_CNV_TIME_OVER             = 1;
U_DTB_CNV_DIVERTOR_EROR         = 2;
U_DTB_CNV_STOPPER_EROR          = 3;
U_DTB_CNV_DOOR_EROR             = 4;
U_DTB_CNV_MOTOR_TRIP            = 5;
U_DTB_CNV_CLAMP_EROR            = 6;
U_DTB_CNV_SMOTOR_EROR           = 7;
U_DTB_CNV_DATA_EROR             = 8;
U_DTB_CNV_SIZEOVER_EROR         = 9;
U_DTB_CNV_UPDOWN_EROR           = 10;
U_DTB_CNV_MOVING_EROR           = 11;
U_DTB_CNV_LIMIT_EROR            = 12;
U_DTB_CNV_EMGSTOP_EROR          = 13;
U_DTB_CNV_LIFT_EROR             = 14;
U_DTB_CNV_SAFETY_SENSOR         = 15;

// 컨베어 PLT SIZE 정의.
U_CTL_PLT_HIGH                  = 3;
U_CTL_PLT_MIDDEL                = 2;
U_CTL_PLT_LOW                   = 1;
U_CTL_STN_PICKING               = 1;
U_CTL_STN_REIN                  = 2;
U_CTL_STN_OUT                   = 3;

// SAFETY DOOR OPEN
U_DTB_SAFETY_DOOR               = 98;


// 에러 발생 구분
U_DTB_OCCUR = 'O';              // 발생
U_DTB_RELEASE = 'R';            // 해제

