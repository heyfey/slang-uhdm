// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  sequence s2(x, y);
    x ##1 y;
  endsequence
  assert property (@(posedge clk) s2(a, b));
endmodule
