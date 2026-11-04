// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] a, input logic [1:0] b, output logic o);
  ifc u (.clk(|((a << b) ** 1)));
  assign o = u.sig[0];
endmodule
