// § castTsPushLaidOut131
`define LONGMAC(x) \
  x + \
  1
module top (input logic [7:0] a, output logic [5:0] o);
  assign o = 6'(`LONGMAC(a)) + 6'(a);
endmodule
