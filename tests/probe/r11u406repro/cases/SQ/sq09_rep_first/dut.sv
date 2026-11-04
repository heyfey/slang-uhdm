// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence s;
    @(posedge clk) a [*2] ##1 b;
  endsequence
  assert property (s);
endmodule
