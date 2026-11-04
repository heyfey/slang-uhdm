// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic clk, input logic [2:0] k, input logic [1:0] x);
  always_ff @(posedge clk) bs.wdtxx[k+1 -: 2] <= x;
endmodule
module top(input logic clk, input logic [2:0] k, input logic [1:0] x); tif b(); m u(b, clk, k, x); endmodule
