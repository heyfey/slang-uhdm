// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c);
  property p;
    @(posedge clk) a |-> ##1 b ##1 c;
  endproperty
  assert property (p);
endmodule
