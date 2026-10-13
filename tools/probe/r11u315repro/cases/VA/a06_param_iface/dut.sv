// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface pifc #(parameter int W = 2) (input logic clk);
  logic [W-1:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  pifc #(.W(4)) u (.clk(a & b));
  assign o = u.sig[0];
endmodule
