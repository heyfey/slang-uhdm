// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s1;
    a ##1 b;
  endsequence
  sequence s2;
    s1 ##1 c;
  endsequence
  assert property (@(posedge clk) s2);
endmodule
