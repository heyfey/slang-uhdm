// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence seq;
    @(posedge clk) a ##1 b;
  endsequence
  assert property (seq);
endmodule
