// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (a, b, o);
  input a, b;
  output o;
  wire c;
  assign c = a;
  ifc u (.clk(c ^ b));
  assign o = u.sig[0];
endmodule
