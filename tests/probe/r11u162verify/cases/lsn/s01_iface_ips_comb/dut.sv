// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic [2:0] k, input logic [1:0] x);
  always_comb bs.wdtxx[k +: 2] = x;
endmodule
module top(input logic [2:0] k, input logic [1:0] x); tif b(); m u(b, k, x); endmodule
