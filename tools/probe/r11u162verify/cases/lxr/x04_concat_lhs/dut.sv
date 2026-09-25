// § lvIdxPathIsRead154
interface tif; logic [1:0] a; logic [1:0] b; endinterface
module mem(tif bus, input logic clk, input logic [15:0] d);
  logic [7:0] m [4];
  logic [7:0] n [4];
  always_ff @(posedge clk) {m[bus.a], n[bus.b]} <= d;
endmodule
module top(input logic clk, input logic [15:0] d); tif b(); mem u(b, clk, d); endmodule
