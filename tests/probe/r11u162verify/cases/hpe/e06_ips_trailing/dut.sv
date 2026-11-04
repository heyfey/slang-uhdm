// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t req_dly [2]; endinterface
module m(tif bus, input logic [2:0] k, output logic [1:0] o);
  assign o = bus.req_dly[1].adr[k +: 2];
endmodule
module top(input logic [2:0] k, output logic [1:0] o); tif b(); m u(b, k, o); endmodule
