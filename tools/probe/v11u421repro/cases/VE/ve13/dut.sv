// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  property p(x, y); @(posedge clk) x ##1 y; endproperty
  initial expect (p(a, b)) n = 1; else n = 2;
endmodule
