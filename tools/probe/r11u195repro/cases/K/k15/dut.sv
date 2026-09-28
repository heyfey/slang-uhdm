// § procNetMidSelDotted195 — grid K/k15 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t [1:0] regs, output logic [31:0] a);
  always_comb a = regs[1].key[2].q;
endmodule
