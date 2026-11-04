// § lvIdxPathIsRead154
module top(input logic clk, input logic [7:0] d);
  typedef struct packed { logic [3:0] adr; } s_t;
  s_t s;
  logic [7:0] m [0:15][0:3];
  always @(posedge clk) m[s.adr + 1][s.adr[1:0]] <= d;
endmodule
