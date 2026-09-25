// § lvIfacePathBitSelWhole154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic clk, input logic x, input logic [2:0] k);
  always_ff @(posedge clk) bs.wdtxx[k] <= x;
endmodule
module top(input logic clk, input logic x, input logic [2:0] k); tif b(); m u(b, clk, x, k); endmodule
