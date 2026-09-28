// § ifacePortDeclTsAtPortDecl205 — r11u217 p07: non-ANSI interface ports with keyword-typed ports whose type carries no range: input byte, input int, input integer, input var logic, input tri1, input uwire
interface ifc (a, c, d, g, e, u);
  input var logic [3:0] a;
  input byte c;
  input int d;
  input integer g;
  input tri1 [3:0] e;
  input uwire [3:0] u;
  logic [3:0] w;
  assign w = a ^ c[3:0] ^ d[3:0] ^ g[3:0] ^ e ^ u;
endinterface
module top (input logic [3:0] i, output logic [3:0] y);
  ifc u (.a(i), .c(8'(i)), .d(int'(i)), .g(32'(i)), .e(i), .u(i));
  assign y = u.w;
endmodule
