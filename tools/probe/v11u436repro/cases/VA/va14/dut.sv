// § uninstIfaceAssertListing436
interface ifa(input clk, input a);
A1: assert property (@(posedge clk) a);
endinterface
interface ifb(input clk, input a);
A1: assert property (@(posedge clk) a);
endinterface
module top(input clk, input a);
ifb u(clk, a);
endmodule
