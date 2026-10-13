// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic b, output logic o);
  child c0 (.clk(a & b), .o(o));
endmodule
