// § procNetMidSelDotted195 — grid K/k09 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output rp::key_t b, output logic [3:0] c);
  always_comb b = reg2hw.key[2];
  always_comb c = reg2hw.ctrl;
endmodule
