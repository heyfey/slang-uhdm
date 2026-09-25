// § lvIdxPathIsRead154
module top(input logic clk, input logic [3:0] a);
  typedef struct packed { logic [3:0] adr; } s_t;
  s_t s;
  assign s = a;
  logic [31:0] m [0:15];
  always @(posedge clk) m[s.adr][7:0] <= 8'h1;
endmodule
