// § lvIfacePathBitSelWhole154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic clk, input logic x);
  always_ff @(posedge clk) bs.wdtxx [ 2 ] <= x;
endmodule
module top(input logic clk, input logic x); tif b(); m u(b, clk, x); endmodule
