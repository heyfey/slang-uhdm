// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  initial begin
    expect (@(posedge clk) a ##1 b) begin n = 1; end else begin n = 2; end
  end
endmodule
