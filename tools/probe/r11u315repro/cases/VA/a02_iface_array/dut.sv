// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  ifc u [2] (.clk(a & b));
  assign o = u[0].sig[0];
endmodule
