// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  property p;
    @(posedge clk) a |=> b ##1 c ##2 d;
  endproperty
  assert property (p);
endmodule
