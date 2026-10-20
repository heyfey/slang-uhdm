// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  always @(posedge clk) begin
    expect (@(posedge clk) a |-> ##[1:2] b) n++; else n--;
  end
endmodule
