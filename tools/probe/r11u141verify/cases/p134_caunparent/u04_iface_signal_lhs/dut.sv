// § contAssignLhsTsUnparented134
// case u04: the whole-struct LHS is a signal of an interface instance, the typedef from a package
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
endpackage
interface ifc;
  p::s_t s;
endinterface
module top(input logic [7:0] i, output logic [3:0] o);
  ifc u();
  assign u.s = i;
  assign o = u.s.b;
endmodule
