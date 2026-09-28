// § ifacePortDeclTsAtPortDecl205 — r11u217 p06: a non-ANSI interface port list with two declarators in one declaration, a signed net keyword `input wire signed [3:0]`, a scalar `input wire`, and a port whose range uses an interface parameter; instantiated twice with two parameter values
interface ifc #(parameter int W = 4) (a, b, s, e);
  input wire [W-1:0] a, b;
  input wire signed [3:0] s;
  input wire e;
  logic [W-1:0] w;
  assign w = e ? a : b ^ W'(s);
endinterface
module top (input logic [7:0] i, output logic [3:0] y, output logic [7:0] z);
  ifc u (.a(i[3:0]), .b(i[7:4]), .s(i[3:0]), .e(i[0]));
  ifc #(.W(8)) v (.a(i), .b(~i), .s(i[3:0]), .e(i[1]));
  assign y = u.w;
  assign z = v.w;
endmodule
