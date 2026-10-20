// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  initial begin
    expect (@(posedge clk) a ##1 b) lp: n = 1; else le: n = 2;
  end
endmodule
