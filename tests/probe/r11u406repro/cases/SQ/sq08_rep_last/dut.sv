// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence s;
    @(posedge clk) b ##1 a [*2];
  endsequence
  assert property (s);
endmodule
