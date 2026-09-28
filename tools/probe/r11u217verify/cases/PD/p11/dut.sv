// § ifacePortDeclTsAtPortDecl205 — r11u217 p11: non-ANSI interface port bounds written as a LONG parameter name minus one, a product, and a parenthesized expression (`[WIDTH-1:0]`, `[2*W-1:0]`, `[(W)-1:0]`)
interface ifc #(parameter int WIDTH = 4, parameter int W = 2) (a, b, c);
  output wire [WIDTH-1:0] a;
  output wire [2*W-1:0] b;
  output wire [(W)-1:0] c;
  assign a = '1;
  assign b = '0;
  assign c = '1;
endinterface
module top (output logic [3:0] y, output logic [3:0] z, output logic [1:0] x);
  ifc u (y, z, x);
endmodule
