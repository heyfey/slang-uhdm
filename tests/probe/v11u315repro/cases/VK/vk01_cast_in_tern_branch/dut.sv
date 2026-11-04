// § ifaceConnCastTsNamedByPort315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic s, input logic [1:0] a, input logic b, output logic o);
  ifc u (.clk(s ? 1'(a) : b));
  assign o = u.sig[0];
endmodule
