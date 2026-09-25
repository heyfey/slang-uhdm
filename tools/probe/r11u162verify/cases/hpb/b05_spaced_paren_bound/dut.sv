// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m(tif bus, output logic [3:0] o);
  localparam int GW = 4;
  assign o = bus.wdt[ (GW - 1) : 0 ];
endmodule
module top(output logic [3:0] o); tif b(); m u(b, o); endmodule
