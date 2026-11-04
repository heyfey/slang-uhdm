// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
R1: restrict property (@(posedge clk) a);
endinterface
