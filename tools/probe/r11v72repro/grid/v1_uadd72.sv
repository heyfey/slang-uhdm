// v11u72 BREAK ARM 1 — THE `+` ARM HAS AN UNSIGNED HALF THE VALUE TABLE DOES
// NOT MODEL.  ExprEval.cpp:3267-3296: `vpiAddOp` picks the UNSIGNED arm
// (`get_uvalue`, `UINT:` + vpiUIntConst) unless one REDUCED operand is a
// constant of type vpiIntConst / vpiStringConst / vpiRealConst / vpiDecConst.
// `red72Int64` applies the SIGNED arm unconditionally.  Does the landed
// encoding gate (`caSubstLeafCt56 == vpiIntConst`) fence every cell where the
// two disagree?  Each member read EXACTLY ONCE.
package p1;
  localparam bit [63:0] HU = 64'hFFFFFFFFFFFFFFFE;  // hex-encoded leaf
  localparam bit [63:0] DU = 64'd18446744073709551614; // DECIMAL-encoded leaf
  localparam int        BIG = 2000000000;
  localparam int        K   = 6;
  typedef struct packed {
    logic [63:0] a;  // HU + 1      unsigned arm?  digits 18446744073709551615
    logic [63:0] b;  // DU + 1      DEC leaf -> signed arm?  int64 -1
    logic [63:0] c;  // DU + DU     int64 -4
    logic [63:0] d;  // HU + HU     int64 -4
    logic [31:0] e;  // BIG + BIG   CONTROL (golden UINT:4000000000)
    logic [63:0] f;  // DU - 1      sub is ALWAYS signed: int64 -3
    logic [63:0] g;  // HU - 1      int64 -3
    logic [31:0] h;  // K + 1       CONTROL
  } c_t;
  localparam c_t A = '{a: HU+1, b: DU+1, c: DU+DU, d: HU+HU, e: BIG+BIG,
                       f: DU-1, g: HU-1, h: K+1};
endpackage
module v1_uadd72 #(parameter p1::c_t C = p1::A)
                 (output logic [63:0] y0, output logic [63:0] y1,
                  output logic [63:0] y2, output logic [63:0] y3,
                  output logic [31:0] y4, output logic [63:0] y5,
                  output logic [63:0] y6, output logic [31:0] y7);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g; assign y7 = C.h;
endmodule
