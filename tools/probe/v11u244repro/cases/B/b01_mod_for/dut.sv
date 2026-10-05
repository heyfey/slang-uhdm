// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; logic [3:0] e; } dat_t;
module top(input logic clk, input logic [7:0] x [4], output dat_t s);
  always_ff @(posedge clk)
    for (int i = 0; i < 4; i++) s.d[i*8 +: 8] <= x[i];
  always_comb s.e = '0;
endmodule
