// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; } dat_t;
module top(input logic [7:0] x [4], output dat_t s);
  for (genvar g = 0; g < 4; g++) begin : G
    always_comb s.d[g*8 +: 8] = x[g];
  end
endmodule
