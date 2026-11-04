// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  initial begin
    expect (@(posedge clk) a ##1 b) begin end else begin end
  end
endmodule
