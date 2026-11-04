// § modDynTdDefNetCopy442
module top(input logic clk);
  typedef int q_t [$];
  q_t q;
  always @(posedge clk) q.push_back(1);
endmodule
