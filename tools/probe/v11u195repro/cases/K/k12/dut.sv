// § procNetMidSelDotted195 — v11u195 fresh: an interface-free struct net declared in the module (a plain wire, not a port), always_ff with if
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input logic clk, input rp::reg2hw_t r, input logic [1:0] i, output logic [3:0] o);
  rp::reg2hw_t n;
  assign n = r;
  wire rp::reg2hw_t w;
  assign w = r;
  always_ff @(posedge clk) if (w.key[0].qe) o <= w.key[i].q;
endmodule
