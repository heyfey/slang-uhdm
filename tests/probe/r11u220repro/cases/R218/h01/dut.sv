// § lvIdxPathRangeTailIsRead218
module top(input logic clk, input logic [7:0] x);
  typedef struct packed { logic [7:0] addr; logic [3:0] a; } s_t;
  s_t s;
  logic [7:0] mem [16];
  always_ff @(posedge clk) mem[s.addr[3:0]] <= x;
endmodule
