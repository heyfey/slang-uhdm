// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t tab [2][3]; endinterface
module m(tif bus, output logic [7:0] o);
  assign o = bus.tab[1][2].adr;
endmodule
module top(output logic [7:0] o); tif b(); m u(b, o); endmodule
