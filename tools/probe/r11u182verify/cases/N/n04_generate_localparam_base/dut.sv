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
module top ();
  if (1) begin : g
    localparam p::cfg_t L = p::mk(24, 3);
    localparam int X = L.A / L.B;
    localparam int Y = p::D.A / 4;
    leaf #(.W(X), .V(Y)) u();
  end
endmodule
