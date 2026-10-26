// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
assert property (@(posedge clk) a);
endinterface
