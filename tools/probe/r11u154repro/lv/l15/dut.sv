// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x);
  typedef struct packed { logic [7:0] adr; } r_t;
  typedef struct packed { r_t rqq; } s_t;
  s_t sv;
  always_ff @(posedge clk) sv.rqq.adr[3:0] <= x;
endmodule
