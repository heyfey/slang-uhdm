// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; logic [7:0] w [16]; endinterface
module mem(tif bs, input logic clk, input logic [7:0] d);
  always @(posedge clk) bs.w[bs.adr] <= d;
endmodule
module top(input logic clk, input logic [7:0] d); tif b(); mem u(b, clk, d); endmodule
