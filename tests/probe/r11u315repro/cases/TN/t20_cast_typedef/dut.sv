// § ifaceConnCastTsNamedByPort315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
typedef logic bit1_t;
module top (input logic [1:0] a, input logic b, output logic o);
  ifc u (.clk(b ^ bit1_t'(a)));
  assign o = u.sig[0];
endmodule
