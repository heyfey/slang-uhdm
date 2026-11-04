// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  ifc u (.clk(a | signed'(b)));
  assign o = u.sig[0];
endmodule
