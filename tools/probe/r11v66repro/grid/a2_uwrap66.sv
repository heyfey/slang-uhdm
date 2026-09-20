// v11u66 adversarial arm a2 — THE UNSIGNED WRAP.
// `dimRedCtExpr79` answers `vpiIntConst` for EVERY Subtract, whatever the
// operand signedness.  The patch then prints the SETTER's own value, and for
// an UNSIGNED setter slang's own arithmetic wraps to a huge positive
// (3 - 5 in `bit [31:0]` is 4294967294), where Surelog's ExprEval does the
// subtraction in int64 and would write -2.  If golden says INT:-2 and the
// patch says INT:4294967294, the DECOMPILE and the VALUE move AWAY.
package qa2;
  localparam bit [31:0]     KU = 3;
  localparam int unsigned   IU = 3;
  localparam bit [7:0]      BU = 3;
  localparam bit [63:0]     LU = 3;
  typedef struct packed {
    logic [31:0] a;   // KU - 5        unsigned 32 -> 4294967294
    logic [31:0] b;   // IU - 5        unsigned int -> 4294967294
    logic [7:0]  c;   // BU - 5        unsigned 8 -> 254
    logic [63:0] d;   // LU - 5        unsigned 64 -> 18446744073709551614
    logic [31:0] e;   // 3 - 5         SIGNED control -> -2
    logic [31:0] f;   // KU * 2        unsigned, no wrap -> 6 (control)
    logic [63:0] g;   // 64'hFFFFFFFFFFFFFFFF - 1   the top of uint64
  } ca2_t;
  localparam ca2_t A2 = '{a: KU-5, b: IU-5, c: BU-5, d: LU-5, e: 3-5,
                          f: KU*2, g: 64'hFFFFFFFFFFFFFFFF - 1};
endpackage
module a2_uwrap66 #(parameter qa2::ca2_t C = qa2::A2)
                  (output logic [31:0] y0, output logic [31:0] y1,
                   output logic [31:0] y2, output logic [63:0] y3,
                   output logic [31:0] y4, output logic [31:0] y5,
                   output logic [63:0] y6);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g;
endmodule
