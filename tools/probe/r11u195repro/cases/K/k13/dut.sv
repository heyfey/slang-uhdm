// § procNetMidSelDotted195 — grid K/k13 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic [31:0] a, output logic [3:0] b);
  function automatic int f(input int i); return i + 1; endfunction
  always_comb begin
    a = reg2hw.key[f(1)].q;
    b = reg2hw.key[1].q[f(2):0];
    a[f(reg2hw.key[2].q[3:0])] = 1'b0;
  end
endmodule
