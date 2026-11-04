// § aliasTdMembTsInstAtAlias484 (package alias imported by two modules, each with a variable)
package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module s1(input logic [7:0] i, output logic [3:0] o);
  import u::*;
  op2_t w;
  assign w = i;
  assign o = w.a;
endmodule
module s2(input logic [7:0] i, output logic [3:0] o);
  u::op2_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, o2);
  s1 a(i, o1);
  s2 b(i, o2);
endmodule
