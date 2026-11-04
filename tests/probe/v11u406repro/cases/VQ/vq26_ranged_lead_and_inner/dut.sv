// § seqNestLeadingDelay406v
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  property p;
    @(posedge clk) a |-> ##[1:3] b ##1 c ##[0:2] d;
  endproperty
  assert property (p);
endmodule
