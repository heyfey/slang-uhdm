// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  sequence s(x = a, y = b);
    x ##1 y;
  endsequence
  assert property (@(posedge clk) s());
endmodule
