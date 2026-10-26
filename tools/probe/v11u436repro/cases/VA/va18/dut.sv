// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
property P(logic x, logic y); @(posedge clk) x |-> ##1 y; endproperty
A1: assert property (P(a, b));
A2: assert property (P(b, a));
endinterface
