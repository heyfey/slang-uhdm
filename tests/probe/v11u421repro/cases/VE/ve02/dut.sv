// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  initial begin
    expect (@(posedge clk) a ##1 b) n = 1; else ;
  end
endmodule
