// § procNetMidSelDotted195 — grid K/k07 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic [31:0] a, output logic [31:0] b);
  always_comb begin
    a = 0;
    for (int i = 0; i < 2; i++) a = a + reg2hw.key[i].q;
  end
  assign b = reg2hw.key[1].q;
endmodule
