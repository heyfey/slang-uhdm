// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x);
  typedef struct packed { logic [7:0] inner; } i_t;
  typedef struct packed { i_t outer; logic [7:0] q; } s_t;
  s_t sv;
  always_ff @(posedge clk) sv.outer.inner[5:2] <= x;
endmodule
