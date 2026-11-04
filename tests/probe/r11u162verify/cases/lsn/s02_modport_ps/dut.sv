// § lvPathSelNamedByChain154
interface tif; logic [7:0] wdtxx; modport wr(output wdtxx); endinterface
module m(tif.wr bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs.wdtxx[7:4] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(.bs(b.wr), .clk(clk), .x(x)); endmodule
