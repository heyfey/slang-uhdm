// § ifacePortDeclTsAtPortDecl205: two declarators in one port declaration, each redeclared
interface ifc (a, b);
  output [3:0] a, b;
  wire [3:0] a = 4'h1;
  wire [3:0] b = 4'h2;
endinterface
module top(output logic [3:0] y, output logic [3:0] z);
  ifc i (.a(y), .b(z));
endmodule
