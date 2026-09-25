// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic [3:0] x);
  assign bs.wdtxx[7:4] = x;
endmodule
module top(input logic [3:0] x); tif b(); m u(b, x); endmodule
