// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic a, input logic b, output logic o);
  ifc u (.clk(a ^ b));
  assign o = u.sig[0];
endmodule
module top (input logic a, input logic b, output logic o, output logic p);
  mid m1 (.a(a), .b(b), .o(o));
  mid m2 (.a(b), .b(a), .o(p));
endmodule
