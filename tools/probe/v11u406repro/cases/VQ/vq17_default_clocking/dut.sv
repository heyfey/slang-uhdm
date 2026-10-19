// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  default clocking cb @(posedge clk); endclocking
  sequence s;
    a ##1 b;
  endsequence
  assert property (s);
endmodule
