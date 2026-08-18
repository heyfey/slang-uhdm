// r10v64 ARM 2 — DECLARED-TYPE MATRIX for § elabCaPortParamPaCopy64's
// consumer (srlgAdjustSize) plus every FENCE target (enum / struct / real /
// string / >64-bit / untyped / ranged-untyped).  MEASUREMENT ONLY.
package pv2;
  typedef enum logic [2:0] { Q0 = 3'd0, Q2 = 3'd2 } q_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef logic [3:0] nib_t;
endpackage

module tInt  #(parameter int          P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tIntU #(parameter int unsigned P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tByte #(parameter byte         P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tShort#(parameter shortint     P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tLong #(parameter longint      P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tIntg #(parameter integer      P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tBit  #(parameter bit          P = 1)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tLogic#(parameter logic        P = 1)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tBitV #(parameter bit   [7:0]  P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tLogV #(parameter logic [15:0] P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tLogS #(parameter logic signed [7:0] P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tReg  #(parameter reg   [3:0]  P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tTdef #(parameter pv2::nib_t   P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
// ---- FENCE targets ------------------------------------------------------
module tEnum #(parameter pv2::q_t     P = pv2::Q2)(input c, output [3:0] o);
  localparam int W = 4; if (P != pv2::Q0) begin : g assign o = c ? W'(P) : 4'd1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tStru #(parameter pv2::s_t     P = 8'h24)(input c, output [3:0] o);
  if (P != 0) begin : g assign o = c ? P.a : P.b; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tWide #(parameter logic [127:0] P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P[3:0] + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tReal #(parameter real         P = 4.0)(input c, output [3:0] o);
  if (P != 0.0) begin : g assign o = c ? 4'd2 : 4'd1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tUnty #(parameter             P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tRUnt #(parameter      [7:0]  P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule

module topV2(input c);
  localparam int         SI = 1 * 2;
  localparam bit [3:0]   SH = 4'h2;
  localparam bit [3:0]   SB = 4'b0010;
  localparam int         SN = -3;
  wire [3:0] o01,o02,o03,o04,o05,o06,o07,o08,o09,o10,o11,o12,o13,o14,o15,o16;
  wire [3:0] o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32;
  wire [3:0] o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48;
  wire [3:0] o49,o50,o51,o52,o53,o54,o55,o56,o57,o58,o59,o60,o61,o62,o63,o64;
  wire [3:0] o65,o66,o67,o68,o69,o70,o71,o72,o73,o74,o75,o76;
  tInt  #(.P(2))    a01(c,o01); tInt  #(.P(4'h2)) a02(c,o02); tInt  #(.P(SI)) a03(c,o03); tInt  #(.P(SB)) a04(c,o04);
  tIntU #(.P(2))    a05(c,o05); tIntU #(.P(4'h2)) a06(c,o06); tIntU #(.P(SI)) a07(c,o07); tIntU #(.P(SB)) a08(c,o08);
  tByte #(.P(2))    a09(c,o09); tByte #(.P(4'h2)) a10(c,o10); tByte #(.P(SI)) a11(c,o11); tByte #(.P(SN)) a12(c,o12);
  tShort#(.P(2))    a13(c,o13); tShort#(.P(4'h2)) a14(c,o14); tShort#(.P(SI)) a15(c,o15); tShort#(.P(SN)) a16(c,o16);
  tLong #(.P(2))    a17(c,o17); tLong #(.P(4'h2)) a18(c,o18); tLong #(.P(SI)) a19(c,o19); tLong #(.P(SN)) a20(c,o20);
  tIntg #(.P(2))    a21(c,o21); tIntg #(.P(4'h2)) a22(c,o22); tIntg #(.P(SI)) a23(c,o23); tIntg #(.P(SN)) a24(c,o24);
  tBit  #(.P(1))    a25(c,o25); tBit  #(.P(1'b1)) a26(c,o26); tBit  #(.P(SI)) a27(c,o27); tBit  #(.P(SB)) a28(c,o28);
  tLogic#(.P(1))    a29(c,o29); tLogic#(.P(1'b1)) a30(c,o30); tLogic#(.P(SI)) a31(c,o31); tLogic#(.P(SB)) a32(c,o32);
  tBitV #(.P(2))    a33(c,o33); tBitV #(.P(4'h2)) a34(c,o34); tBitV #(.P(SI)) a35(c,o35); tBitV #(.P(SN)) a36(c,o36);
  tLogV #(.P(2))    a37(c,o37); tLogV #(.P(4'h2)) a38(c,o38); tLogV #(.P(SI)) a39(c,o39); tLogV #(.P(SB)) a40(c,o40);
  tLogS #(.P(2))    a41(c,o41); tLogS #(.P(4'h2)) a42(c,o42); tLogS #(.P(SI)) a43(c,o43); tLogS #(.P(SN)) a44(c,o44);
  tReg  #(.P(2))    a45(c,o45); tReg  #(.P(4'h2)) a46(c,o46); tReg  #(.P(SI)) a47(c,o47); tReg  #(.P(SB)) a48(c,o48);
  tTdef #(.P(2))    a49(c,o49); tTdef #(.P(4'h2)) a50(c,o50); tTdef #(.P(SI)) a51(c,o51); tTdef #(.P(SB)) a52(c,o52);
  tEnum #(.P(pv2::Q2)) a53(c,o53); tEnum a54(c,o54);
  tStru #(.P(8'h24)) a55(c,o55); tStru a56(c,o56);
  tWide #(.P(2))    a57(c,o57); tWide #(.P(4'h2)) a58(c,o58); tWide #(.P(SI)) a59(c,o59); tWide #(.P(SB)) a60(c,o60);
  tReal #(.P(2.5))  a61(c,o61); tReal a62(c,o62);
  tUnty #(.P(2))    a63(c,o63); tUnty #(.P(4'h2)) a64(c,o64); tUnty #(.P(SI)) a65(c,o65); tUnty #(.P(SB)) a66(c,o66);
  tRUnt #(.P(2))    a67(c,o67); tRUnt #(.P(4'h2)) a68(c,o68); tRUnt #(.P(SI)) a69(c,o69); tRUnt #(.P(SB)) a70(c,o70);
  tInt  a71(c,o71); tIntU a72(c,o72); tByte a73(c,o73); tBitV a74(c,o74); tUnty a75(c,o75); tRUnt a76(c,o76);
endmodule
