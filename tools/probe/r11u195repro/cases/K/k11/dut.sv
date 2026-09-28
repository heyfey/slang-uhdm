// § procNetMidSelDotted195 — grid K/k11 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic [3:0][31:0] a, output logic [1:0][1:0] b);
  for (genvar g = 0; g < 4; g++) begin : gl
    always_comb a[g] = reg2hw.key[g].q;
  end
  for (genvar x = 0; x < 2; x++) begin : o
    for (genvar y = 0; y < 2; y++) begin : n
      always_comb b[x][y] = reg2hw.key[x*2+y].qe;
    end
  end
endmodule
