// § hpPartSelBoundNamesBySelect154
interface tif; logic [7:0] wdt; logic [7:0] rdt; logic write_en; endinterface
module m(tif bus, input logic [2:0] k, output logic [1:0] o);
  assign o = bus.wdt[k +: 2];
endmodule
module top(input logic [2:0] k, output logic [1:0] o); tif b(); m u(b, k, o); endmodule
