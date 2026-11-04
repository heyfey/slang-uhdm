// § procNetMidSelDotted195 — grid K/k04 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic [31:0] a, output logic c);
  always_ff @(reg2hw) begin
    a <= reg2hw.key[1].q;
    if (reg2hw.key[2].qe) c <= 1'b1;
  end
  initial c = reg2hw.key[0].qe;
endmodule
