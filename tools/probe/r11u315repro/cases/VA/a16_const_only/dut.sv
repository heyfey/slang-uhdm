// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (output logic o);
  ifc u (.clk(1'b1 & 1'b0));
  assign o = u.sig[0];
endmodule
