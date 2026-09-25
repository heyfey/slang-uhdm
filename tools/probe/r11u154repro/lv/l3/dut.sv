// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic x); typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t; s_t sv;
  always_ff @(posedge clk) sv.wdtxx[2] <= x;
endmodule
