// § ifacePortDeclTsAtPortDecl205 — r11u217 p05: the same non-ANSI port shapes in a MODULE (the law is interface-only: control) and in an interface with a port list declared over two lines and a comment between keyword and range
module m (a, b, o);
  input wire [3:0] a;
  input logic [3:0] b;
  output logic [3:0] o;
  assign o = a ^ b;
endmodule
interface ifc (a,
               b);
  input wire /* the net */ [3:0] a;
  input logic
        [3:0] b;
  logic [3:0] w;
  assign w = a & b;
endinterface
module top (input logic [3:0] i, output logic [3:0] y, output logic [3:0] z);
  m mm (.a(i), .b(i), .o(z));
  ifc u (.a(i), .b(i));
  assign y = u.w;
endmodule
