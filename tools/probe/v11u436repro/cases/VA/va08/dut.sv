// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
property P(x = a); @(posedge clk) x; endproperty
A1: assert property (P());
endinterface
