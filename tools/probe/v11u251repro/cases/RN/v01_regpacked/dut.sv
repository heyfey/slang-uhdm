// § regTdArrElabIsNet251 (a reg typedef with a packed dimension: target syntax RegType with dims)
typedef reg [7:0] r_t [4];
module top(input logic clk);
  r_t m;
  always_ff @(posedge clk) m[0] <= 8'h1;
endmodule
