// § seqConcatNestsRight406
module top;
  logic clk, a, b, c;
  assert property (@(posedge clk) a ##1 b ##1 c);
  property p2;
    @(posedge clk) a |-> b ##1 c ##1 a;
  endproperty
  cover property (p2);
endmodule
