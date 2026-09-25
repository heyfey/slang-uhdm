// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  s_t sa [2];
  always_ff @(posedge clk) sa[1].wdtxx[3:0] <= x;
endmodule
