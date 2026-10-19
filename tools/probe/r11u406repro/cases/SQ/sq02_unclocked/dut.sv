// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence s1;
    a ##1 b;
  endsequence
  assert property (@(posedge clk) s1);
endmodule
