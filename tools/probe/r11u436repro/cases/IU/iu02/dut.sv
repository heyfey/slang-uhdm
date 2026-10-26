// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
property P(sig);
  @(posedge clk) !$isunknown(sig);
endproperty
A1: assert property (P(a));
A2: assert property (P(b));
endinterface
