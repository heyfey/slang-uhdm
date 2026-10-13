// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic [1:0] b, output logic o);
  ifc u (.clk(a & 1'(b)));
  assign o = u.sig[0];
endmodule
