// § uninstIfaceAssertListing436
interface ifc #(int N = 4) (input clk, input [N-1:0] a);
covergroup cg @(posedge clk);
  coverpoint a;
endgroup
cg c = new;
endinterface
