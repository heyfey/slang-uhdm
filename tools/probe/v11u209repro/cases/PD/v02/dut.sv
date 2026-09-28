// § ifacePortDeclTsAtPortDecl205: a var-keyword logic port declaration in a non-ANSI interface
interface ifc (a, o);
  input var logic [3:0] a;
  output logic [3:0] o;
  assign o = a;
endinterface
module top(input logic [3:0] x, output logic [3:0] y);
  ifc i (.a(x), .o(y));
endmodule
