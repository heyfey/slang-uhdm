// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
wire w;
assign w = a;
A1: assert property (@(posedge clk) w);
always @(posedge clk) assert (a);
endinterface
