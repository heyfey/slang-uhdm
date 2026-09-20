// r11u72 arm t1 — THE REDUCE TABLE's VALUE HALF IS int64 ARITHMETIC.
// `ExprEval::reduceExpr` reads every reduced operand with `get_value` as
// int64_t and applies the arm in int64_t (UHDM templates/ExprEval.cpp:3454
// `val0 - val1`, :3490 `val0 * val1`, :3415 `-val0`, :3301 the signed `+`,
// :3726 `%`, :3782 `**`, :3822 `/`) — it NEVER wraps at the expression's own
// width.  slang's evaluation does.  Each member is read EXACTLY ONCE.
package q1;
  localparam int        BIG = 2000000000;   // 2e9: 2*BIG overflows int32
  localparam int        K   = 6;
  localparam bit [31:0] KU  = 3;            // UNSIGNED 32
  localparam bit [7:0]  BU  = 3;            // UNSIGNED 8
  localparam bit [63:0] LU  = 3;            // UNSIGNED 64
  localparam int        NEG = -7;
  localparam shortint   SH  = 16'sd30000;
  typedef struct packed {
    logic [31:0] a;   // BIG * 2      int64 4000000000  / slang -294967296
    logic [63:0] b;   // BIG * BIG    int64 4000000000000000000 (fits int64)
    logic [31:0] c;   // 2 ** 40      int64 1099511627776 / slang 0
    logic [31:0] d;   // K ** 2       36            CONTROL (both agree)
    logic [31:0] e;   // SH * SH      900000000     CONTROL
    logic [31:0] f;   // KU * 2       6             CONTROL (unsigned, no wrap)
    logic [31:0] g;   // KU - 5       int64 -2      / slang 4294967294
    logic [7:0]  h;   // BU - 5       int64 -2      / slang 254
    logic [63:0] i;   // LU - 5       int64 -2      / slang 18446744073709551614
    logic [31:0] j;   // NEG / 2      int64 -3
    logic [31:0] k;   // NEG % 2      int64 -1
    logic [31:0] l;   // -BIG         -2000000000   CONTROL
    logic [31:0] m;   // -(BIG * 2)   int64 -4000000000
    logic [31:0] n;   // BIG + BIG    the `+` arm (UINT side of the table)
  } c1_t;
  localparam c1_t A1 = '{a: BIG*2, b: BIG*BIG, c: 2**40, d: K**2, e: SH*SH,
                         f: KU*2, g: KU-5, h: BU-5, i: LU-5, j: NEG/2,
                         k: NEG%2, l: -BIG, m: -(BIG*2), n: BIG+BIG};
endpackage
module t1_arith72 #(parameter q1::c1_t C = q1::A1)
                  (output logic [31:0] y0, output logic [63:0] y1,
                   output logic [31:0] y2, output logic [31:0] y3,
                   output logic [31:0] y4, output logic [31:0] y5,
                   output logic [31:0] y6, output logic [7:0]  y7,
                   output logic [63:0] y8, output logic [31:0] y9,
                   output logic [31:0] y10, output logic [31:0] y11,
                   output logic [31:0] y12, output logic [31:0] y13);
  assign y0 = C.a;  assign y1 = C.b;  assign y2 = C.c;  assign y3 = C.d;
  assign y4 = C.e;  assign y5 = C.f;  assign y6 = C.g;  assign y7 = C.h;
  assign y8 = C.i;  assign y9 = C.j;  assign y10 = C.k; assign y11 = C.l;
  assign y12 = C.m; assign y13 = C.n;
endmodule
