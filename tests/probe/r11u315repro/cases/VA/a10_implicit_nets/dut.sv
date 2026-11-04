// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (output logic o);
  wire x, y;
  ifc u (.clk(x | y));
  assign o = u.sig[0];
endmodule
