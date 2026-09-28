// § procNetMidSelDotted195 — v11u195 fresh: a procedural force on a net-based mid select (the lvalue), and a case on one
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input logic [1:0] i, output logic [3:0] o);
  rp::reg2hw_t w;
  wire rp::reg2hw_t n = w;
  initial force n.key[1].q = 4'h3;
  always_comb
    case (n.key[i].q)
      4'h1: o = n.key[0].q;
      default: o = 4'h0;
    endcase
endmodule
