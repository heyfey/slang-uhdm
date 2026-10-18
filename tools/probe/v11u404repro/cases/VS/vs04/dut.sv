// § seqMatchItemsDropped404
module top;
  logic clk, a, b;
  int x;
  property p4;
    int v;
    @(posedge clk) (a, v = x)[*2] |-> b;
  endproperty
  assert property (p4);
endmodule
