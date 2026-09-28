// § procNetMidSelDotted195 — v11u195 fresh: an event control and a nonblocking read on net-based mid selects
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic p);
  always @(posedge reg2hw.key[1].qe) p <= reg2hw.key[2].qe;
endmodule
