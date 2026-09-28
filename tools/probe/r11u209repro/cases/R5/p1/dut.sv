// § ifacePortDeclTsAtPortDecl205: a non-ANSI interface input redeclared as a wire in the body
interface ifc (a, b);
  input [3:0] a;
  output [3:0] b;
  wire [3:0] a;
  wire [3:0] b = a;
endinterface
module top (input logic [3:0] x, output logic [3:0] y);
  ifc u (x, y);
endmodule
