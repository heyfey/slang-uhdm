// § expectActionBlockStmts421
module c(input logic clk, a, b);
  int n;
  initial expect (@(posedge clk) a ##1 b) n = 1; else n = 0;
endmodule
module top(input logic clk, a, b);
  c u1(clk, a, b);
  c u2(clk, b, a);
endmodule
