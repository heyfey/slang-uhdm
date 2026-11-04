// § seqMatchItemsDropped404
module top(input clk, input a, input b, input [7:0] d);
  property p1;
    int v;
    @(posedge clk) (a, v = d) ##1 b;
  endproperty
  assert property (p1);
  sequence s1;
    @(posedge clk) a ##1 b;
  endsequence
  assert property (s1);
endmodule
