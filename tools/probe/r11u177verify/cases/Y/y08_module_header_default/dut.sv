// § memLeftFormalArgLoc169 § ppOutputFile166 § mlArgLocFileAtActual177v
`include "defs.svh"
package p;
  typedef struct packed { int unsigned A; int unsigned B; int unsigned C; } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = x / 8;
    c.C = y;
    return c;
  endfunction
endpackage
module top #(parameter p::cfg_t C = p::mk(`XW,
                                          4)) ();
  leaf #(.W(C.A), .V(C.B), .U(C.C)) u();
endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
