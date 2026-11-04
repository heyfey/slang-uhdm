// § procNetMidSelDotted195 — grid K/k05 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input var rp::reg2hw_t reg2hw, output logic [31:0] a);
  always_comb a = reg2hw.key[1].q;
endmodule
