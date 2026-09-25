// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m(tif bus, input logic clk, output logic [3:0] o);
  localparam int GW = 4;
  function automatic int hi(int a); return a - 1; endfunction
  always_ff @(posedge clk) o <= bus.wdt[hi(GW):0];
endmodule
module top(input logic clk, output logic [3:0] o); tif b(); m u(b, clk, o); endmodule
