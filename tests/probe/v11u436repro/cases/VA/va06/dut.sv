// § uninstIfaceAssertListing436
interface ifc(input clk);
logic a, b;
modport mp(input a, output b);
A1: assert property (@(posedge clk) a |=> b);
endinterface
