//*************************************************************************
rMesgType = array[0..4] of Integer;                 // 0 : CMD
                                                    // 1 : 1번작업 로딩위치
                                                    // 2 : 1번작업 언로딩 위치
                                                    // 3 : 2번작업 로딩위치
                                                    // 4 : 2번작업 언로딩 위치
aMesgType = array[0..255] of byte;

// API 통해서 받아 온 것
RTV_WORK = record
    workNo        : Integer;
    orderClass    : Integer;
    fromStation   : Integer;
    toStation     : Integer;
    orderPriority : Integer;
    status        : Integer;                                   // 작업 상태
    setTime       : TDateTime;                                 // 명령 API 수신 시간
    sendTime      : TDateTime;                                 // 명령 전송 시간
    ackTime       : TDateTime;                                 // 명령 응답 시간
    sendCount     : Integer;                                   // 명령 전송 횟수
    rtvNo         : Integer;                                   // 할당 된 rtv-Syncro 대비 (수신 Data)
    passCount     : Integer;                                   // 작업 할당 Pass 된 횟 수
end;

RTV_INFO = record
    rtvNo           : Integer;                                 // rtv
    operationMode   : Boolean;                                 // Job mode 작업모드: true=작업가능, false=작업불가
    loopTime        : TDateTime;						       // 프로그램 루프 시간
    enqTime         : TDateTime;							   // 상태문의 송신 시간
    answerTime      : TDateTime;						       // 상태문의 수신 시간
    active          : Boolean;                                 // THREAD  active status
    workType        : Integer;                                 // Current work type
    enable          : Boolean;                                 // 장비/통신 enable
    commStatus      : Boolean;                                 // communication status
    currentPosition : Integer;                                 // 현재위치
    emergency       : Boolean;                                 // 비상정지
    error           : Boolean;                                 // 에러 발생 유무
    errorCode       : Integer;                                 // 에러코드
    errorSubCode    : Integer;                                 // 에러서브코드
    status          : Integer;                                 // 상태 (1. 대기, 2. 작중)
    rtv_from        : Integer;                                 // 현재 작업 FROM
    rtv_to          : Integer;                                 // 현재 작업 TO
    speed           : Integer;                                 // 주행속도
    exists          : array [1..U_MAX_RTV_BED] of Boolean;     // 화물감지 유무
    timeOver        : Boolean;                                 // 타임오버
    completeFlag    : Boolean;                                 // 완료신호
end;


