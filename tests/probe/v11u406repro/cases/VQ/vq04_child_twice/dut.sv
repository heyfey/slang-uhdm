// § sequenceDeclListed406
module child(input logic clk, input logic a, input logic b);
  sequence s;
    a ##1 b;
  endsequence
  assert property (@(posedge clk) s);
endmodule
module top(input logic clk, input logic a, input logic b);
  child c1(clk, a, b);
  child c2(clk, b, a);
endmodule
