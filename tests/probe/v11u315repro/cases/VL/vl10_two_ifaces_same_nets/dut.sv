// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  ifc u1 (.clk(a & b));
  ifc u2 (.clk(b & a));
  assign o = u1.sig[0] | u2.sig[0];
endmodule
