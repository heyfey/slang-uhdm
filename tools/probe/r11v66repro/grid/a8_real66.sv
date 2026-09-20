// v11u66 adversarial arm a8 — CAN THE TABLE ANSWER `INT` WHERE GOLDEN IS NOT?
// `dimRedCtExpr79` answers `vpiIntConst` UNCONDITIONALLY for `-`, `*`, `/`,
// `%`, `**`.  ExprEval's own arms fall back to a REAL constant whenever the
// integer read is invalid (ExprEval.cpp:3461-3474, :3495-…).  If golden ever
// writes `REAL:`/ct 6 or a plain `UINT:` on one of those arms while the table
// says INT, the law re-spells a cell golden does NOT spell that way — the one
// road to a MOVED-WRONG, because the judge reads VpiConstType and
// VpiDecompile (generated `constant::Compare` + `expr::Compare`).
package qa8;
  localparam int  K  = 4;
  localparam real R  = 2.5;
  localparam int  Z  = 0;
  typedef struct packed {
    logic [31:0] a;   // K ** -1        a NEGATIVE exponent
    logic [31:0] b;   // 2 ** 40        a power that leaves 32 bits
    logic [31:0] c;   // K * 2          control
    logic [31:0] d;   // $rtoi(R) * 2   a system call under a multiply
    logic [31:0] e;   // K - Z          a subtract by a zero-valued name
    logic [31:0] f;   // (K ** 2) - 1   a power under a subtract
  } ca8_t;
  localparam ca8_t A8 = '{a: K ** -1, b: 2 ** 40, c: K * 2,
                          d: $rtoi(R) * 2, e: K - Z, f: (K ** 2) - 1};
endpackage
module a8_real66 #(parameter qa8::ca8_t C = qa8::A8)
                 (output logic [31:0] y0, output logic [31:0] y1,
                  output logic [31:0] y2, output logic [31:0] y3,
                  output logic [31:0] y4, output logic [31:0] y5);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c;
  assign y3 = C.d; assign y4 = C.e; assign y5 = C.f;
endmodule
