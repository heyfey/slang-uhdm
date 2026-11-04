// § seqNestLeadingDelay406v
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  property p;
    @(posedge clk) a |-> ##1 b ##1 c ##1 d;
  endproperty
  assert property (p);
endmodule
