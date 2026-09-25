// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [1:0] x, input logic [2:0] k); typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t; s_t sv;
  always_ff @(posedge clk) sv.wdtxx[k +: 2] <= x;
endmodule
