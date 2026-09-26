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
module child #(parameter p::cfg_t Cfg = p::D,
  localparam int X = Cfg.A / Cfg.B) ();
  leaf #(.W(X)) u();
endmodule
module top ();
  child c1();
  child c2();
endmodule
