// § uninstIfaceAssertListing436
interface ifc(input clk, input a);
function automatic bit ok(bit v); return v; endfunction
A1: assert property (@(posedge clk) ok(a)) else $display("x");
endinterface
