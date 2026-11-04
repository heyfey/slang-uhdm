// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m #(parameter int GW = 4) (tif bus, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bus.wdt[GW-1:0] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule
