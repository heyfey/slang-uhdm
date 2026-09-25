// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs.wdtxx[ 3 : 0 ] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule
