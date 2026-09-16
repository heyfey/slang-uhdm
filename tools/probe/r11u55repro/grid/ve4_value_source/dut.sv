// r11u55 ROAD E arm — WHERE THE SUBSTITUTED CONSTANT IS STAMPED, and in what
// ENCODING.  reduceExpr RETURNS the object the value came from, so the location
// is the SOURCE of the value, not the read.  Cut every source shape:
//   * a plain decimal literal in the pattern            (n)
//   * an expression element `K + 1`                     (m)  -> element start
//   * a based HEX literal                               (h)
//   * a based BINARY literal                            (b)
//   * a member whose value comes from ANOTHER localparam (r)
//   * a member left to the type DEFAULT (no pattern key) (d)
// and read the VpiSize / VpiConstType / VpiDecompile of each folded elab Rhs.
package p;
  localparam int K = 3;
  typedef struct packed {
    int unsigned n;
    int unsigned m;
    logic [15:0] h;
    logic [7:0]  b;
    int unsigned r;
    int unsigned d;
  } cfg_t;
  localparam int unsigned OTHER = 41;
  localparam cfg_t LIT = '{n: 3,
                           m: K + 1,
                           h: 16'hBEEF,
                           b: 8'b1010_0101,
                           r: OTHER,
                           default: 0};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [31:0] o_n, output logic [31:0] o_m,
            output logic [31:0] o_h, output logic [31:0] o_b,
            output logic [31:0] o_r, output logic [31:0] o_d);
  assign o_n = CFG.n;
  assign o_m = CFG.m;
  assign o_h = CFG.h;
  assign o_b = CFG.b;
  assign o_r = CFG.r;
  assign o_d = CFG.d;
endmodule
