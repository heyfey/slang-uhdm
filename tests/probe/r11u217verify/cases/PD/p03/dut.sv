// § ifacePortDeclTsAtPortDecl205 — r11u217 p03: two packed dimensions with a net-type keyword, a data-type keyword and no keyword, and an UNPACKED dimension, on non-ANSI interface ports
interface ifc (a, b, c, d);
  input wire [1:0][3:0] a;
  input logic [1:0][1:0] b;
  input [2:0][1:0] c;
  input logic [3:0] d [2];
  logic [3:0] w;
  assign w = a[0] ^ {b[1], b[0]} ^ c[1] ^ d[1];
endinterface
module top (input logic [7:0] i, input logic [3:0] u0 [2], output logic [3:0] y);
  ifc u (.a(i), .b(i[3:0]), .c(i[5:0]), .d(u0));
  assign y = u.w;
endmodule
