// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
sequence S(x); x ##1 b; endsequence
property P; @(posedge clk) S(a); endproperty
A1: assert property (P);
endinterface
