// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  for (genvar i = 0; i < 2; i++) begin : g
    initial expect (@(posedge clk) a ##i b) n = i; else n = -1;
  end
endmodule
