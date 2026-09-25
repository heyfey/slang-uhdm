// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t req_dly [2]; endinterface
module m(tif bus, output logic [7:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    assign o[g*4 +: 4] = bus.req_dly[g].adr[3:0];
  end
endmodule
module top(output logic [7:0] o); tif b(); m u(b, o); endmodule
