// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; logic [31:0] wdt; modport sub(input adr, input wdt); endinterface
module mem(tif.sub sub, input logic clk);
  logic [31:0] m [0:15];
  always @(posedge clk) m[sub.adr][7:0] <= sub.wdt[7:0];
endmodule
module top(input logic clk); tif b(); mem u(b, clk); endmodule
