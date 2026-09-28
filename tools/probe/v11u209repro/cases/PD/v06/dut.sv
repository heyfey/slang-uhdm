// § ifacePortDeclTsAtPortDecl205: a tri net-type port declaration and an input read by a module through the interface
interface ifc (a, o);
  input tri [3:0] a;
  output [3:0] o;
  wire [3:0] o = ~a;
endinterface
module user(ifc p, output logic [3:0] r);
  assign r = p.o;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  ifc i (.a(x), .o());
  user u (.p(i), .r(y));
endmodule
