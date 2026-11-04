// § ifacePortDeclTsAtPortDecl205: a two-dimensional packed port declaration
interface ifc (o);
  output [1:0][3:0] o;
  wire [1:0][3:0] o = 8'h3c;
endinterface
module top(output logic [7:0] y);
  ifc i (.o(y));
endmodule
