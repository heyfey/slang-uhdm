// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  initial expect (@(posedge clk) a ##1 b) fork n = 1; n = 2; join else n = 3;
endmodule
