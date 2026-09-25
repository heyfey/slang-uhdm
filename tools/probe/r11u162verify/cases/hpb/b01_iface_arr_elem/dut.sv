// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; endinterface
module m(tif bus [2], output logic [3:0] o);
  localparam int GW = 4;
  assign o = bus[1].wdt[GW-1:0];
endmodule
module top(output logic [3:0] o); tif b [2] (); m u(b, o); endmodule
