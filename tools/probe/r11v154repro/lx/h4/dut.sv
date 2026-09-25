// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; logic [7:0] w; endinterface
module mem(tif bs, input logic clk, input logic d);
  always @(posedge clk) bs.w[bs.adr[2:0]] <= d;
endmodule
module top(input logic clk, input logic d); tif b(); mem u(b, clk, d); endmodule
