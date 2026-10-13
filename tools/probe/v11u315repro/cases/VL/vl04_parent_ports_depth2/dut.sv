// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic a, input logic b, output logic o);
  ifc u (.clk(a == b));
  assign o = u.sig[0];
endmodule
module top (input logic a, input logic b, output logic o);
  mid m (.a(a), .b(b), .o(o));
endmodule
