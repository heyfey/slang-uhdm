// § lvIfacePathBitSelWhole154
interface tif; logic [7:0] wdtxx; modport wr(output wdtxx); endinterface
module m(tif.wr bs, input logic x);
  always_comb begin bs.wdtxx = '0; bs.wdtxx[6] = x; end
endmodule
module top(input logic x); tif b(); m u(.bs(b), .x(x)); endmodule
