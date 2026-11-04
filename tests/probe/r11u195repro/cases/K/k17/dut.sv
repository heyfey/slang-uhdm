// § procNetMidSelDotted195 — grid K/k17 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
`include "kq.svh"
module top(input rp::reg2hw_t reg2hw, output logic [31:0] a);
  always_comb a = `KQ(3);
endmodule
