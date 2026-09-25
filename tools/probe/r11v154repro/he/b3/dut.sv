// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [3:0] lo; logic [3:0] hi; } a_t; typedef struct packed { a_t [1:0] el; } req_t; endpackage
interface tif; ip::req_t req; endinterface
module m(tif bus, output logic [3:0] o);
  assign o = bus.req.el[1].hi;
endmodule
module top(output logic [3:0] o); tif b(); m u(b, o); endmodule
