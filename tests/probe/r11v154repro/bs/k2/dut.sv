// § lvIfacePathBitSelWhole154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic x);
  assign bs.wdtxx[5] = x;
endmodule
module top(input logic x); tif b(); m u(b, x); endmodule
