// § mopPkgBaseReduces174v
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
  localparam cfg_t E = '{A: 16, B: 4, C: 1};
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top import p::*; #(localparam int X = D.A * E.B, localparam int Y = (D.B + E.C) / 2) ();
  leaf #(.W(X), .V(Y)) u();
endmodule
