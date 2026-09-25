// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; logic [7:0] rdt; logic write_en; endinterface
module m(tif bus, input logic clk, output logic [3:0] o);
  localparam int GW = 4;
  always_ff @(posedge clk) o <= bus.wdt[GW-1:0];
endmodule
module top(input logic clk, output logic [3:0] o); tif b(); m u(b, clk, o); endmodule
