// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [1:0] i, input logic [3:0] d);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t [3:0] sa;
  always_ff @(posedge clk) sa[i].f[3:0] <= d;
endmodule
