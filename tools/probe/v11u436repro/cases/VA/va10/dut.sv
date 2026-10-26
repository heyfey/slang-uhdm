// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
A1: assert property (@(posedge clk) a);
endinterface
module top(input clk, input a);
endmodule
