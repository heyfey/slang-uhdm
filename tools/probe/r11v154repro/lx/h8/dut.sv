// § lvIdxPathIsRead154
interface tif; logic [7:0] mem [4][4]; endinterface
module m(tif bs, input logic clk, input logic [1:0] i, input logic [1:0] j, input logic [7:0] d);
  always_ff @(posedge clk) bs.mem[i][j] <= d;
endmodule
module top(input logic clk, input logic [1:0] i, j, input logic [7:0] d); tif b(); m u(b, clk, i, j, d); endmodule
