// § seqConcatNestsRight406
module top;
  logic clk, a, b, c;
  sequence s;
    @(posedge clk) a ##1 b ##2 c;
  endsequence
  property p;
    @(posedge clk) a ##1 b ##1 c;
  endproperty
  assert property (s);
  assert property (p);
endmodule
