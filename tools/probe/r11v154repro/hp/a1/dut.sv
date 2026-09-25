// § hpPartSelBoundNamesBySelect154
package q; localparam int W = 4; endpackage
interface tif; logic [7:0] wdt; endinterface
module m(tif bus, input logic clk, output logic [3:0] o);
  always_ff @(posedge clk) o <= bus.wdt[q::W-1:0];
endmodule
module top(input logic clk, output logic [3:0] o); tif b(); m u(b, clk, o); endmodule
