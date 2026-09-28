// § ifacePortDeclTsAtPortDecl205: a parameterized width, the interface instantiated twice with different widths
interface ifc #(parameter int W = 4) (o);
  output [W-1:0] o;
  wire [W-1:0] o = '1;
endinterface
module top(output logic [3:0] y, output logic [7:0] z);
  ifc #(.W(4)) i (.o(y));
  ifc #(.W(8)) j (.o(z));
endmodule
