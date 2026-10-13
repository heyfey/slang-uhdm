// § ifaceConnCastTsNamedByPort315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int W = 1) (input logic [3:0] a, output logic o);
  ifc u (.clk(W'(a)));
  assign o = u.sig[0];
endmodule
