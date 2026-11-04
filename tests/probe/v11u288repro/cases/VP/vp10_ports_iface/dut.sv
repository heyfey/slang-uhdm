// § parenCastReadsCastSyntax288 — a parenthesized cast as a named and a positional port actual, inside an interface body and one instance level down
interface ifc(input logic [7:0] x); int q; assign q = (int'(x)) + 2; endinterface
module s(input int i, output int o); assign o = i; endmodule
module mid(input logic [7:0] x, output int o, o2);
  s u1(.i((int'(x))), .o(o));
  s u2((byte'(x)), o2);
  ifc ii(x);
endmodule
module top(input logic [7:0] x, output int o, o2); mid m(.*); endmodule
