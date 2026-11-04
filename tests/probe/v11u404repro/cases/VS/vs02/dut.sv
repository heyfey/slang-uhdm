// § seqMatchItemsDropped404
module top;
  logic clk, a, b;
  int x, y;
  property p2;
    int v, w;
    @(posedge clk) (a, v = x, w = y) |=> (v == w);
  endproperty
  assert property (p2);
endmodule
