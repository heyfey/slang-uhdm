// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  property p;
    @(posedge clk) a ##1 b;
  endproperty
  assert property (p);
endmodule
