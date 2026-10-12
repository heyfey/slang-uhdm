// § parenCastReadsCastSyntax288 — port actuals, a net declaration assignment, an interface body and an implicit net
interface ifc(input logic [7:0] a);
  logic [31:0] b;
  assign b = (int'(a)) + 1;
endinterface
module s(input logic [31:0] i, output logic [31:0] o);
  assign o = i;
endmodule
module top(input logic [7:0] x, output logic [31:0] o1, o2);
  wire [31:0] nd = (int'(x)) - 1;
  ifc u_if(.a(x));
  s u1(.i((int'(x))), .o(o1));
  s u2(.i((shortint'(nd))), .o(o2));
  assign imp = (bit'(x[0]));
endmodule
