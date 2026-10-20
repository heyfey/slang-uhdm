// § expectActionBlockStmts421
interface ifc(input logic clk);
  logic a, b; int n;
  initial expect (@(posedge clk) a ##1 b) n = 1; else n = 0;
endinterface
module top(input logic clk); ifc u(clk); endmodule
