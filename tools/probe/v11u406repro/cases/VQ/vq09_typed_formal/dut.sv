// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s(logic x);
    x ##1 b ##1 c;
  endsequence
  assert property (@(posedge clk) s(a));
endmodule
