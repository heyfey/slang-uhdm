// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
sequence S; a ##1 b; endsequence
property P; @(posedge clk) S |-> b; endproperty
A1: assert property (P);
A2: assert property (@(posedge clk) S);
endinterface
