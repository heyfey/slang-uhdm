// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s(x, y, z);
    x ##1 y ##1 z;
  endsequence
  assert property (@(posedge clk) s(a, b, c));
endmodule
