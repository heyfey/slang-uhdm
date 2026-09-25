// § hpPartSelBoundNamesBySelect154
interface tif #(parameter int W = 8); logic [W-1:0] wdt; endinterface
module m #(parameter int GW = 4) (tif bus, input logic clk, output logic [GW-1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [GW-1:0] t;
    always_ff @(posedge clk) t <= bus.wdt[GW-1+i:i];
  end
  assign o = g[0].t;
endmodule
module top(input logic clk, output logic [3:0] o); tif #(8) b(); m #(4) u(b, clk, o); endmodule
