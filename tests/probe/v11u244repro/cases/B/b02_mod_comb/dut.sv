// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; } dat_t;
module top(input logic [7:0] x [4], input logic [1:0] k, output dat_t s, output dat_t r);
  always_comb begin
    s = '0;
    for (int i = 0; i < 4; i++) s.d[(3-i)*8 -: 8] = x[i];
  end
  always_comb begin
    r = '0;
    r.d[k*8 +: 8] = x[k];
  end
endmodule
