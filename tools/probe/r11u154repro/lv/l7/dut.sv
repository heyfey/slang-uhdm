// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; logic [7:0] q; endinterface
module m(tif busxx, input logic [3:0] x);
  assign busxx.wdtxx[3:0] = x;
endmodule
module top(input logic [3:0] x); tif b(); m u(b, x); endmodule
