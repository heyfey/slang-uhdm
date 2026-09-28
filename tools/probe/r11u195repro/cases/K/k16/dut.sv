// § procNetMidSelDotted195 — grid K/k16 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
  typedef struct packed { reg2hw_t [1:0] r; } top_t;
endpackage
module top(input rp::top_t t, output logic [31:0] a, output logic b);
  always_comb begin
    a = t.r[1].key[2].q;
    b = t.r[0].key[3].qe;
  end
endmodule
