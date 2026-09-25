// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; modport sub(input adr); endinterface
module mem(tif.sub sub, input logic clk, input logic [1:0] d);
  logic [31:0] m;
  always @(posedge clk) m[sub.adr*2 +: 2] <= d;
endmodule
module top(input logic clk, input logic [1:0] d); tif b(); mem u(b, clk, d); endmodule
