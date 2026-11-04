// § ifacePortDeclTsAtPortDecl205 — r11u217 p10: a parameterized non-ANSI interface port REDECLARED in the body (`input [W-1:0] a; wire [W-1:0] a;`), and one with no redeclaration, instantiated with the default width
interface ifc #(parameter int W = 4) (a, b);
  input [W-1:0] a;
  output [W-1:0] b;
  wire [W-1:0] a;
  assign b = ~a;
endinterface
module top (input logic [3:0] i, output logic [3:0] y);
  ifc u (.a(i), .b(y));
endmodule
