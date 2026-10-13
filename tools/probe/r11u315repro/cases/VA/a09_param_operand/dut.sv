// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter logic P = 1) (input logic a, input logic b, output logic o);
  ifc u (.clk(a & P & b));
  assign o = u.sig[0];
endmodule
