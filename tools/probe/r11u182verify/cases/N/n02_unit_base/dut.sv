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
localparam p::cfg_t G = p::mk(40, 8);
localparam p::cfg_t H = '{A: 12, B: 3, C: 0};
module top #(localparam int X = G.A / G.B, localparam int Y = H.A / H.B) ();
  leaf #(.W(X), .V(Y)) u();
endmodule
