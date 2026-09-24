// § defNetEndOnlyLoc130
// case a04: package-scoped struct packed array inside an interface, the interface instantiated
package pk;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
interface ifc;
  pk::s_t [1:0] x;
endinterface
module top(output logic [5:0] o);
  ifc u();
  assign o = u.x;
endmodule
