// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
property P; int x; @(posedge clk) (a, x = 1) |=> x == 1; endproperty
A1: assert property (P);
endinterface
