// § ifacePortDeclTsAtPortDecl205 — r11u217 p01: non-ANSI interface ports with the net-type keywords input tri, input wand and input wor
interface ifc (a, b, c);
  input tri [3:0] a;
  input wand [3:0] b;
  input wor [3:0] c;
  logic [3:0] w;
  assign w = a ^ b ^ c;
endinterface
module top (input logic [3:0] i, output logic [3:0] y);
  ifc u (i, i, i);
  assign y = u.w;
endmodule
