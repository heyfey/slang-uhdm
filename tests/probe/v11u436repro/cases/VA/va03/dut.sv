// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
M1: assume property (@(posedge clk) a);
C1: cover property (@(posedge clk) a ##1 b);
endinterface
