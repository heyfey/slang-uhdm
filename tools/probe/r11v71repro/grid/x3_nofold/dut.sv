// v11u71 x3 — DOES GOLDEN ALWAYS CARRY A CONSTANT ON THE "SHARE" HALF?  The
// pass-68 gate declined it; the cut fires it.  If elaboration leaves any of
// these Rhs shapes UNFOLDED in golden, minting a constant is a regression.
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inner_t;
  typedef struct packed { inner_t i; int unsigned n; logic [3:0] x; } cfg_t;
  localparam cfg_t LIT = '{i: '{a: 8'h11, b: 8'h22}, n: 300, x: 4'bz1x0};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  if (1) begin : g
    logic [31:0] n_nested;   // a NESTED member select
    logic [31:0] n_whole;    // the WHOLE inner struct
    logic [31:0] n_xz;       // an X/Z-valued member
    logic [31:0] n_expr;     // the member inside a wider expression
    logic [31:0] n_bitsel;   // a BIT SELECT of a member
    logic [31:0] n_partsel;  // a PART SELECT of a member
    assign n_nested = CFG.i.a;
    assign n_whole  = CFG.i;
    assign n_xz     = CFG.x;
    assign n_expr   = CFG.n + 32'd1;
    assign n_bitsel = CFG.n[3];
    assign n_partsel= CFG.n[7:4];
    assign o = {32'd0, n_nested} ^ {32'd0, n_whole} ^ {32'd0, n_xz}
             ^ {32'd0, n_expr} ^ {32'd0, n_bitsel} ^ {32'd0, n_partsel};
  end
endmodule
