// § lvPathSelNamedByChain154
module top(input logic clk, input logic [1:0] x, input logic [2:0] k);
  typedef struct packed { logic [7:0] adr; } r_t;
  typedef struct packed { r_t rqq; } s_t;
  s_t sv;
  always_ff @(posedge clk) sv.rqq.adr[k +: 2] <= x;
endmodule
