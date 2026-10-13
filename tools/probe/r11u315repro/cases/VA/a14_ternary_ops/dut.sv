// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, input logic s, output logic o);
  ifc u (.clk(s ? (a & b) : ~c));
  assign o = u.sig[0];
endmodule
