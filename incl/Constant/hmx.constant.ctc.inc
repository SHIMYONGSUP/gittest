//----------------------[ CONTROL CHARACTER DEFINE ]------------------------
// 통신 전문 관련
// # -> Char 값으로 인식
// $ -> 16진 표기를 의미 (C의 0x와 같음)
U_CTC_ENQ_CMD  = #$A1;
U_CTC_ENQ_ACK  = #$B1;
U_CTC_ORD_CMD  = #$A2;
U_CTC_ORD_ACK  = #$B2;

U_CTC_NULL  = #$0;
U_CTC_STX   = #$2;
U_CTC_ETX   = #$3;
U_CTC_EOT   = #$4;
U_CTC_ENQ   = #$5;
U_CTC_ACK   = #$6;
U_CTC_LF    = #$0A;
U_CTC_FF    = #$0C;
U_CTC_CR    = #$0D;
U_CTC_CRLF  = #$0D#$0A;
U_CTC_CRLF2 = #$0D#$0A#$0D#$0A;
U_CTC_DLE   = #$10;
U_CTC_NAK   = #$19;

U_CTB_ENQ_CMD = $A1;
U_CTB_ENQ_ACK = $B1;
U_CTB_ORD_CMD = $A2;
U_CTB_ORD_ARK = $B2;

U_CTB_NULL = $00;
U_CTB_STX  = $02;
U_CTB_ETX  = $03;
U_CTB_EOT  = $04;
U_CTB_ENQ   = $05;
U_CTB_ACK   = $06;
U_CTB_LF    = $0A;
U_CTB_FF    = $0C;
U_CTB_CR    = $0D;
U_CTB_DLE   = $10;
U_CTB_NAK   = $19;
U_CTB_SYN   = $16;

U_CTB_ETM   = $F5;
U_AGV_DLM   = $3B;

// 사용 허가
U_DTD_TRUE                 = 1;
U_DTD_FALSE                = 2;
