// 작업상태
U_COM_NONE  = 0;        //  0  : 없음
U_COM_FRST  = 1;        //  1  : WCS 예약 (제어)
U_COM_RESV  = 2;        //  2  : 예약(RTV Controller)
U_COM_WAIT  = 3;        //  3  : 전송대기 (제어)
U_COM_PEND  = 4;        //  4  : 작업지시 전송보류(미처리상태)
U_COM_COMT  = 5;        //  5  : 전송완료 (통신)
U_COM_EXEC  = 6;        //  6  : 실행처리 (제어)
U_COM_LOAD  = 7;        //  7  : 로딩완료
U_COM_COMP  = 8;        //  8  : 작업완료 (제어/통신)
U_COM_REST  = 9;        //  9  : 완료리셋 (제어)
U_COM_EROR  = 10;       //  10 : 작업이상 (제어/통신)
U_COM_RTRY  = 11;       //  11 : 재실행
U_COM_RECT  = 12;       //  12 : 완료리셋전송 (통신)

// 설비상태
U_STS_NONE = 1;         //  1 : 대기 (작업명령 수신대기)
U_STS_PROG = 2;         //  2 : 작업중 (명령 수신)
U_STS_EROR = 3;         //  3 : 에러
