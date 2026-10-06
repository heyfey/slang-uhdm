// § forMultiInitAssign258 (two initializers in an always_ff block with a clocked loop body)
module m(input logic clk); int i, j; logic [7:0] y;
  always_ff @(posedge clk) begin for (i = 0, j = 0; i < 4; i++) y <= y + j; end
endmodule
module top; logic clk; m u(.clk(clk)); endmodule
