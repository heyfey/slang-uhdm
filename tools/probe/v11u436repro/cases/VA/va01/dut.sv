// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
property P; @(posedge clk) a |-> b; endproperty
A1: assert property (P);
endinterface
