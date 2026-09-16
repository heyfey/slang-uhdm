// r11v55 VERIFIER arm — THE GUARDS' EDGES.  The law declines when the value
// does not fit 64 bits, when the member width is 0, when the value has X/Z, and
// when an ENUM member's literal is a named enumerator.  Golden's reduceExpr has
// none of those guards, so each cell is either an agreed decline or a
// divergence that must be recorded.
package p;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic [95:0] wide;     // > 64 bits
    e_t          ev;       // enum member, named enumerator literal
    logic [7:0]  xz;       // X/Z bits in the literal
    logic [7:0]  ok;       // control
  } cfg_t;
  localparam cfg_t LIT = '{wide: 96'hDEAD_BEEF_CAFE_BABE_1234_5678,
                           ev:   E_B,
                           xz:   8'b1010_xx01,
                           ok:   8'd7};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [95:0] o_wide, output logic [31:0] o_ev,
            output logic [7:0]  o_xz,   output logic [7:0]  o_ok);
  assign o_wide = CFG.wide;
  assign o_ev   = CFG.ev;
  assign o_xz   = CFG.xz;
  assign o_ok   = CFG.ok;
endmodule
