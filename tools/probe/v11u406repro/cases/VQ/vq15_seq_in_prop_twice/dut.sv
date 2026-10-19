// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  property p;
    s |-> c;
  endproperty
  assert property (p);
  cover property (s);
endmodule
