// § escNameSpanSites295
module dut (input logic clk, input logic a, input logic b);
  property \p.rop ;
    @(posedge clk) a |-> b;
  endproperty
  assert property (\p.rop );
endmodule
