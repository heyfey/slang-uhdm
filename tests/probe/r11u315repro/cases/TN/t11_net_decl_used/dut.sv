// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  wire w = a;
  ifc u (.clk(w & b));
  assign o = u.sig[0];
endmodule
