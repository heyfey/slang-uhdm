// § hpPartSelBoundNamesBySelect154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t req; endinterface
module m(tif bus, output logic [3:0] o);
  localparam int GW = 4;
  assign o = bus.req.adr[GW-1:0];
endmodule
module top(output logic [3:0] o); tif b(); m u(b, o); endmodule
