// § expectActionBlockStmts421
program top(input logic clk, a, b);
  int n;
  initial expect (@(posedge clk) a ##1 b) n = 1; else $display("fail %0d", n);
endprogram
