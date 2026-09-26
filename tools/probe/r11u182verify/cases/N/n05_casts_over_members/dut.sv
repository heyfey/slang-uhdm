// § elabStructMemberOpFoldUnlocated174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = y;
    c.C = 7;
    return c;
  endfunction
  localparam cfg_t D = mk(64, 5);
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::D, parameter p::cfg_t Pat = '{A: 8, B: 2, C: 1},
  localparam int X = int'(Cfg.A) + 8'(Cfg.B), localparam int Y = int'(Pat.A) / 16'(Pat.B),
  localparam int Z = 32'(p::D.C) * 3) ();
  leaf #(.W(X), .V(Y + Z)) u();
endmodule
