// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, output logic o);
  logic x, y;
  always_comb begin x = a; y = b; end
  ifc u (.clk(x || y));
  assign o = u.sig[0];
endmodule
