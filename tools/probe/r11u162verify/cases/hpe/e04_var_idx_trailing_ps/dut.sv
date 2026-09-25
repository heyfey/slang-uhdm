// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t req_dly [2]; endinterface
module m(tif bus, input logic i, output logic [3:0] o);
  assign o = bus.req_dly[i].adr[3:0];
endmodule
module top(input logic i, output logic [3:0] o); tif b(); m u(b, i, o); endmodule
