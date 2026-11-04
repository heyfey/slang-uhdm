// § procNetMidSelDotted195 — grid K/k14 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [2:0] i, output logic [31:0] a, output logic [7:0] cnt [2]);
  always_comb begin
    a = reg2hw.key[~i].q;
    a = {<<{reg2hw.key[-i].q}};
  end
  always_ff @(reg2hw) cnt[reg2hw.key[1].qe]++;
endmodule
