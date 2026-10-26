// § uninstIfaceAssertListing436
interface ifc #(int W = 4) (input clk, input [W-1:0] a);
A1: assert property (@(posedge clk) a != 0);
endinterface
module top(input clk);
endmodule
