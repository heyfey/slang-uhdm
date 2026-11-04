// § uninstIfaceAssertListing436
interface ifc(input clk, input rst, input a);
property P; @(posedge clk) disable iff (rst) a; endproperty
A1: assert property (P) else $error("bad");
endinterface
