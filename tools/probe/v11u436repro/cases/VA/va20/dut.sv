// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
A1: assert property (@(posedge clk) $rose(a) |-> $past(a) == 0);
endinterface
