// § procNetMidSelDotted195 — grid K/k12 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [3:0][2:0] idx, output logic [31:0] a, output logic [31:0] b);
  always_comb begin
    a = reg2hw.key[reg2hw.ctrl[2:0]].q;
    b = reg2hw.key[idx[reg2hw.key[0].qe]].q;
  end
endmodule
