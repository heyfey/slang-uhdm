// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m(tif bus, output logic [7:0] o);
  localparam int H = 2;
  for (genvar g = 0; g < 2; g++) begin : gl
    assign o[g*4 +: 4] = {2'b0, bus.wdt[H+g:g]};
  end
endmodule
module top(output logic [7:0] o); tif b(); m u(b, o); endmodule
