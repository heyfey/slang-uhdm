// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  logic v;
  assign v = a;
  ifc u (.clk(a & v));
  assign o = u.sig[0];
endmodule
