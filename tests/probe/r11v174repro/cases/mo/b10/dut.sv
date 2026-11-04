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
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::D) ();
  localparam logic [7:0] X = Cfg.A + 8'd1;
  localparam int Y = (Cfg.A) / 2 - Cfg.C;
  localparam int Z = X - 1;
  leaf #(.W(X), .V(Y), .U(Z)) u();
endmodule
