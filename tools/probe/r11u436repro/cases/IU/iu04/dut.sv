// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
property P(sig);
  @(posedge clk) sig;
endproperty
A1: assert property (P(a));
endinterface
module top(input clk, a);
ifc u(.clk(clk), .a(a));
endmodule
