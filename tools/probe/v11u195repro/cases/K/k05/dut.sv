// § procNetMidSelDotted195 — v11u195 fresh: always_latch, final and always_ff with an if on a net-based mid select, the struct net a plain wire not a port
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; } reg2hw_t;
endpackage
module top(input logic clk, input rp::reg2hw_t r, input logic [1:0] i, output logic [3:0] o, output logic [3:0] o2);
  wire rp::reg2hw_t n;
  assign n = r;
  always_latch if (n.key[i].qe) o = n.key[i].q;
  always_ff @(posedge clk) if (n.key[0].qe) o2 <= n.key[i+1].q;
  final $display(n.key[3].q);
endmodule
