// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic b, output logic o, output logic p);
  ifc u (.clk(a | b));
  child c (.clk(a | b), .o(p));
  assign o = u.sig[0];
endmodule
