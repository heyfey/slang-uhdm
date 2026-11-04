// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; logic [7:0] rdt; logic write_en; endinterface
module m(tif bus, output logic [3:0] o);
  localparam int GW = 3;
  assign o = bus.wdt[GW:0];
endmodule
module top(output logic [3:0] o); tif b(); m u(b, o); endmodule
