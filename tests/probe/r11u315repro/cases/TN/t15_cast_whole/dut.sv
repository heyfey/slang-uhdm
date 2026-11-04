// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  ifc u (.clk(1'(a)));
  assign o = u.sig[0];
endmodule
