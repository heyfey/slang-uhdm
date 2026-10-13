// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface outer (input logic a, input logic b);
  ifc u (.clk(a | b));
  logic w;
  assign w = u.sig[0];
endinterface
module top (input logic a, input logic b, output logic o);
  outer ou (.a(a), .b(b));
  assign o = ou.w;
endmodule
