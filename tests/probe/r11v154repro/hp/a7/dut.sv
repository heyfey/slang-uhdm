// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m (tif bus, output logic [3:0] o);
  localparam int GW = 4;
  localparam int LO = 1;
  assign o = bus.wdt[GW:LO];
endmodule
module top(output logic [3:0] o); tif b(); m u(b, o); endmodule
