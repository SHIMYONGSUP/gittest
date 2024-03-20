unit webserver;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, hmx.define, hmx.constant,
  System.JSON, GlobalFnc;

type
  TWebModule2 = class(TWebModule)
    procedure WebModule2DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

    function workForJson(work_no : Integer) : String;
    function rtvForJson(rtv_no : Integer) : String;

    procedure recvProcessing(mnr_code : TArray<string>; recvbuf : String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule2;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TWebModule2.WebModule2DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
    response_content, msg : String;
    mnr_code : TArray<string>;
    //http_code : Integer;
    JSONResponseContent : TJSONObject;
    work_no : Integer;
begin
    //http_code := 100;

    msg := Format('Rx> IP ADDRESS:%s   %s   %s   %s', [Request.RemoteIP,
           Request.InternalPathInfo, Request.Method, Request.Content]);

    DisplayMessage(msg);

    // JSON 객체 생성
    JSONResponseContent := TJSONObject.Create;

    mnr_code := Request.InternalPathInfo.Split(['/']);

    // GET
    if Request.Methodtype = mtGet
    then begin
        if mnr_code[1] = 'WORK'
        then begin
            if mnr_code[2] = 'ALL'
            then begin
                work_no := 0;
                response_content := workForJson(work_no);
            end
            else begin
                work_no := StrToIntDef(mnr_code[3], 0);

                if work_no = 0
                then response_content := 'ERROR : WORK NO. NOT FOUND!!!'
                else response_content := workForJson(work_no);
            end;
        end
        else if mnr_code[1] = 'RTV'
        then begin
            if mnr_code[2] = 'ALL'
            then begin
                work_no := 0;
                response_content := rtvForJson(work_no);
            end
            else begin
                work_no := StrToIntDef(mnr_code[3], 0);

                if work_no = 0
                then response_content := 'ERROR : RTV NO. NOT FOUND!!!'
                else response_content := rtvForJson(work_no);
            end;
        end
        else response_content := 'ERROR : GET URL ERROR!!!';
    end
    // POST
    else if Request.Methodtype = mtPOST
    then begin
        recvProcessing(mnr_code, Request.Content);
    end;

    //Response.StatusCode := http_code mod 1000;

    DisplayMessage(response_content);

    Response.ContentType := 'application/json; charset=utf-8';
    Response.ContentEncoding := 'utf-8';
    Response.Content := response_content;

    JSONResponseContent.DisposeOf;
end;

//------------------------------------------------------------------------------
// CREATE WORK LIST JSON
//------------------------------------------------------------------------------
function TWebModule2.workForJson(work_no : Integer) : String;
var
    JSONObject, JSONworklist : TJSONObject;
    JSONwork : TJSONArray;
    my_i : Integer;
    json_str : String;
begin
    JSONObject := TJSONObject.Create;

    {$REGION 'WORK LIST '}
    try
        JSONwork := TJSONArray.Create;

        for my_i := 1 to U_MAX_WORK do
        begin
            if work_no <> 0
            then begin
                if shmptr^.grp.rtvwork[my_i].workNo <> work_no
                then Continue;
            end;

            JSONworklist := TJSONObject.Create;
            JSONwork.AddElement(JSONworklist);

            JSONworklist.AddPair('workNo',         shmptr^.grp.rtvwork[my_i].workNo);
            JSONworklist.AddPair('orderClass',     shmptr^.grp.rtvwork[my_i].orderClass);
            JSONworklist.AddPair('fromStation',    shmptr^.grp.rtvwork[my_i].fromStation);
            JSONworklist.AddPair('toStation',      shmptr^.grp.rtvwork[my_i].toStation);
            JSONworklist.AddPair('orderPriority',  shmptr^.grp.rtvwork[my_i].orderPriority);
            JSONworklist.AddPair('status',         shmptr^.grp.rtvwork[my_i].status);
            JSONworklist.AddPair('setTime',        shmptr^.grp.rtvwork[my_i].setTime);
            JSONworklist.AddPair('sendTime',       shmptr^.grp.rtvwork[my_i].sendTime);
            JSONworklist.AddPair('ackTime',        shmptr^.grp.rtvwork[my_i].ackTime);
            JSONworklist.AddPair('sendCount',      shmptr^.grp.rtvwork[my_i].sendCount);
            JSONworklist.AddPair('rtvNo',          shmptr^.grp.rtvwork[my_i].rtvNo);
            JSONworklist.AddPair('passCount',      shmptr^.grp.rtvwork[my_i].passCount);
        end;

        JSONObject.AddPair('WORK', JSONwork);
    finally
        json_str := JSONObject.ToString;
        JSONObject.DisposeOf;
    end;
    {$ENDREGION}

    Result := json_str;
end;

//------------------------------------------------------------------------------
// CREATE RTV INFO JSON
//------------------------------------------------------------------------------
function TWebModule2.rtvForJson(rtv_no : Integer) : String;
var
    JSONObject, JSONrtvinfo : TJSONObject;
    JSONrtv : TJSONArray;
    my_i : Integer;
    json_str : String;
begin
    JSONObject := TJSONObject.Create;

    {$REGION 'RTV INFO '}
    try
        JSONrtv := TJSONArray.Create;

        for my_i := 1 to U_MAX_RTV do
        begin
            if rtv_no <> 0
            then begin
                if my_i <> rtv_no
                then Continue;
            end;

            JSONrtvinfo := TJSONObject.Create;
            JSONrtv.AddElement(JSONrtvinfo);

            JSONrtvinfo.AddPair('rtvNo',           shmptr^.grp.rtvinfo[my_i].rtvNo);
            JSONrtvinfo.AddPair('operationMode',   shmptr^.grp.rtvinfo[my_i].operationMode);
            JSONrtvinfo.AddPair('loopTime',        shmptr^.grp.rtvinfo[my_i].loopTime);
            JSONrtvinfo.AddPair('enqTime',         shmptr^.grp.rtvinfo[my_i].enqTime);
            JSONrtvinfo.AddPair('answerTime',      shmptr^.grp.rtvinfo[my_i].answerTime);
            JSONrtvinfo.AddPair('active',          shmptr^.grp.rtvinfo[my_i].active);
            JSONrtvinfo.AddPair('workType',        shmptr^.grp.rtvinfo[my_i].workType);
            JSONrtvinfo.AddPair('enable',          shmptr^.grp.rtvinfo[my_i].enable);
            JSONrtvinfo.AddPair('commStatus',      shmptr^.grp.rtvinfo[my_i].commStatus);
            JSONrtvinfo.AddPair('currentPosition', shmptr^.grp.rtvinfo[my_i].currentPosition);
            JSONrtvinfo.AddPair('emergency',       shmptr^.grp.rtvinfo[my_i].emergency);
            JSONrtvinfo.AddPair('error',           shmptr^.grp.rtvinfo[my_i].error);
            JSONrtvinfo.AddPair('errorCode',       shmptr^.grp.rtvinfo[my_i].errorCode);
            JSONrtvinfo.AddPair('errorSubCode',    shmptr^.grp.rtvinfo[my_i].errorSubCode);
            JSONrtvinfo.AddPair('status',          shmptr^.grp.rtvinfo[my_i].status);
            JSONrtvinfo.AddPair('rtv_from',        shmptr^.grp.rtvinfo[my_i].rtv_from);
            JSONrtvinfo.AddPair('rtv_to',          shmptr^.grp.rtvinfo[my_i].rtv_to);
            JSONrtvinfo.AddPair('speed',           shmptr^.grp.rtvinfo[my_i].speed);
            JSONrtvinfo.AddPair('exists',          shmptr^.grp.rtvinfo[my_i].exists[1]);
            JSONrtvinfo.AddPair('timeOver',        shmptr^.grp.rtvinfo[my_i].timeOver);
            JSONrtvinfo.AddPair('completeFlag',    shmptr^.grp.rtvinfo[my_i].completeFlag);
        end;

        JSONObject.AddPair('RTV', JSONrtv);
    finally
        json_str := JSONObject.ToString;
        JSONObject.DisposeOf;
    end;
    {$ENDREGION}

    Result := json_str;
end;

//------------------------------------------------------------------------------
// POST 데이터 처리
//------------------------------------------------------------------------------
procedure TWebModule2.recvProcessing(mnr_code : TArray<string>; recvbuf : String);
var
    JSONObject : TJSONObject;
    workNo, fromStation, toStation, orderClass, passCount, ord_no, status,
    workType, rtv_no : Integer;
begin
    // String -> JSON parsing & set default key & validation
    JSONObject  := TJSONObject.ParseJSONValue(recvbuf) as TJSONObject;

    if Assigned(JSONObject) = false
    then begin
        DisplayMessage('[ERROR] JSONObject is not assigned');
        JSONObject.Free;
        Exit;
    end;

    // Processing
    if mnr_code[1] = 'WORK'
    then begin
        {$REGION '!!! WORK = REGISTRATION : 데이터 (작번 / 출발지 / 도착지 / 우선순위 / 작업 할당) !!!'}
        if mnr_code[2] = 'REGISTRATION'
        then begin
            JSONObject.TryGetValue<Integer>('workNo',      workNo);
            JSONObject.TryGetValue<Integer>('fromStation', fromStation);
            JSONObject.TryGetValue<Integer>('toStation',   toStation);
            JSONObject.TryGetValue<Integer>('orderClass',  orderClass);
            JSONObject.TryGetValue<Integer>('passCount',   passCount);
            JSONObject.TryGetValue<Integer>('workType',    workType);

            if JSONObject.TryGetValue<Integer>('rtvNo',    rtv_no)
            then begin
                // 수동 명령이나 RTV 호기 할당

            end
            else begin
                // RGC한데 모든걸 맡긴다
                rtv_no := 0;
            end;


            // 역순으로 찾기
            for ord_no := U_MAX_WORK downto 1 do
            begin
                if shmptr^.grp.rtvwork[ord_no].status <> U_COM_NONE
                then break;
            end;

            // index가 작업번호 0 이 아니므로 index+1은 작업번호 0 이다.
            ord_no := ord_no + 1;

            // 버퍼 풀로 작업생성 불가.
            // 정방향 버퍼가 남아있는지 재탐색
            if ord_no > U_MAX_WORK
            then begin
                for ord_no := 1 to U_MAX_WORK do
                begin
                    if shmptr^.grp.rtvwork[ord_no].status = U_COM_NONE
                    then Break;
                end;

                if ord_no > U_MAX_WORK
                then Exit;
            end;

            if workType = U_DTB_EXE_CLS_AUTO
            then begin
                shmptr^.grp.rtvwork[ord_no].workNo        := workNo;
                shmptr^.grp.rtvwork[ord_no].fromStation   := fromStation;
                shmptr^.grp.rtvwork[ord_no].toStation     := toStation;
                shmptr^.grp.rtvwork[ord_no].orderClass    := orderClass;
                shmptr^.grp.rtvwork[ord_no].passCount     := passCount;
                shmptr^.grp.rtvwork[ord_no].orderClass    := U_RTV_FNC_TRAN;
                shmptr^.grp.rtvwork[ord_no].setTime       := Now;

                shmptr^.grp.rtvwork[ord_no].status        := U_COM_FRST;
            end
            else if workType = U_DTB_EXE_CLS_MANUAL
            then begin
                shmptr^.grp.rtvmaul[rtv_no].workNo        := workNo;
                shmptr^.grp.rtvmaul[rtv_no].fromStation   := fromStation;
                shmptr^.grp.rtvmaul[rtv_no].toStation     := toStation;
                shmptr^.grp.rtvmaul[rtv_no].orderClass    := orderClass;
                shmptr^.grp.rtvmaul[rtv_no].passCount     := passCount;
                shmptr^.grp.rtvmaul[rtv_no].orderClass    := U_RTV_FNC_TRAN;
                shmptr^.grp.rtvmaul[rtv_no].setTime       := Now;

                shmptr^.grp.rtvwork[rtv_no].status        := U_COM_WAIT;
            end;

            JSONObject.Free;
            Exit;
        {$ENDREGION}
        end

        else if mnr_code[2] = 'MODIFY'
        then begin
            JSONObject.TryGetValue<Integer>('workNo', workNo);
            JSONObject.TryGetValue<Integer>('status', status);

            for ord_no := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[ord_no].workNo <> workNo
                then Continue;

                shmptr^.grp.rtvwork[ord_no].status := status;

                JSONObject.Free;
                Exit;
            end;
        end
        else if mnr_code[2] = 'DELETE'
        then begin
            JSONObject.TryGetValue<Integer>('workNo', workNo);

            for ord_no := 1 to U_MAX_WORK do
            begin
                if shmptr^.grp.rtvwork[ord_no].workNo <> workNo
                then Continue;

                shmptr^.grp.rtvwork[ord_no].status := U_COM_NONE;

                JSONObject.Free;
                Exit;
            end;
        end;
    end;

    JSONObject.Free;
end;

end.
