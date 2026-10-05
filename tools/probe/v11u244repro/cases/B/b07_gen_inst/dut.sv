// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; } dat_t;
module leaf(input logic [7:0] x [4], output dat_t s);
  always_comb begin
    s = '0;
    for (int i = 0; i < 4; i++) s.d[i*8 +: 8] = x[i];
  end
endmodule
module mid(input logic [7:0] x [4], output dat_t s); leaf l(.x(x), .s(s)); endmodule
module top(input logic [7:0] x [4], output dat_t s [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    mid m(.x(x), .s(s[g]));
  end
endmodule
