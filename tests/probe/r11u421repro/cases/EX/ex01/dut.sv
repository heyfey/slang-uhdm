// § expectActionBlockStmts421
module top(input logic clk, a, b);
  initial begin
    expect (@(posedge clk) a ##1 b) else $error("e");
  end
endmodule
