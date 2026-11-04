// § lvIdxPathIsRead154
`define ADR sub.adr
interface tif; logic [3:0] adr; logic [7:0] wdt; modport sub(input adr, input wdt); endinterface
module mem(tif.sub sub, input logic clk);
  logic [7:0] m [0:15];
  always @(posedge clk) m[`ADR] <= sub.wdt;
endmodule
module top(input logic clk); tif b(); mem u(b, clk); endmodule
