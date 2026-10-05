// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; } dat_t;
module top(input logic clk, input logic [7:0] x, input logic [1:0] k, output dat_t s);
  task automatic put(input int i, input logic [7:0] v);
    s.d[i*8 +: 8] <= v;
  endtask
  always_ff @(posedge clk) put(k, x);
endmodule
