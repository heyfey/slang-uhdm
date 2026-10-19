// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence s3;
    a ##1 b;
  endsequence
  property p;
    @(posedge clk) s3 |-> a;
  endproperty
  assert property (p);
endmodule
