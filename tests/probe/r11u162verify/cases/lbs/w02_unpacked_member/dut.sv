// § lvIfacePathBitSelWhole154
interface tif; logic [3:0] arr [4]; endinterface
module m(tif bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs.arr[2] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule
