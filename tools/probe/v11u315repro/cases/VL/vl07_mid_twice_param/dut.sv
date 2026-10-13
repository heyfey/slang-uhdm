// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid #(parameter int P = 0) (input logic a, input logic b, output logic o);
  ifc u (.clk(a + b + P[0]));
  assign o = u.sig[0];
endmodule
module top (input logic a, input logic b, output logic o1, output logic o2);
  mid #(.P(1)) m1 (.a(a), .b(b), .o(o1));
  mid #(.P(2)) m2 (.a(b), .b(a), .o(o2));
endmodule
