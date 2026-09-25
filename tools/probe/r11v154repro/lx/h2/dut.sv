// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; modport sub(input adr); endinterface
module mem(tif.sub sub, input logic clk, input logic [7:0] d);
  logic [7:0] m [0:15];
  always @(posedge clk) m[sub.adr] <= d;
endmodule
module top(input logic clk, input logic [7:0] d); tif b(); mem u(b, clk, d); endmodule
