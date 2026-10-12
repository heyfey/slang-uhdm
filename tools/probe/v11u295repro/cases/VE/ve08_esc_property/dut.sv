// § escNameSpanSites295
module top(input logic clk, a, b);
  property \p.r ;
    @(posedge clk) a |-> b;
  endproperty
  assert property (\p.r );
endmodule
