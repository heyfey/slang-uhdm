// § uninstIfaceAssertListing436
interface ifc #(int N = 2) (input clk, input a);
for (genvar k = 0; k < N; k++) begin : g
A1: assert property (@(posedge clk) a);
end
endinterface
