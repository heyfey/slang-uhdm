// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
A1: assert property (@(posedge clk) a) else $error("x");
C1: cover property (@(posedge clk) a);
endinterface
module top;
endmodule
