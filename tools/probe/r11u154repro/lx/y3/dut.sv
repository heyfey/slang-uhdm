// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; logic [31:0] wdt; modport sub(input adr, input wdt); endinterface
module mem(tif.sub sub, input logic clk);
  logic [15:0] w; logic o;
  assign o = w[sub.adr];
endmodule
module top(input logic clk); tif b(); mem u(b, clk); endmodule
