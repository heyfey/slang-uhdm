// § hpPartSelBoundNamesBySelect154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; logic [7:0] wdt; logic [7:0] rdt; logic write_en; ip::req_t req; ip::req_t req_dly [2]; endinterface
module m(tif bus, output logic [4:0] o);
  localparam int GW = 4;
  assign o = bus.wdt[GW-1:0] + 1;
endmodule
module top(output logic [4:0] o); tif b(); m u(b, o); endmodule
