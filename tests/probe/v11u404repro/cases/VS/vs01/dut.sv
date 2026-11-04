// § seqMatchItemsDropped404
module top;
  logic clk, a, b, c;
  int x;
  property p1;
    int v;
    @(posedge clk) a ##1 (b, v = x) |-> ##1 (c == v);
  endproperty
  assert property (p1);
endmodule
