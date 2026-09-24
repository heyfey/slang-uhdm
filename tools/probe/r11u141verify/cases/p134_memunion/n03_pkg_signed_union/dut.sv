// § memberAnonUnionAtKeyword134
// case n03: a signed anonymous union member in a package struct typedef
package p;
  typedef struct packed {
    union packed signed { logic [3:0] a; logic [3:0] b; } u;
    logic [3:0] c;
  } s_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  p::s_t v;
  assign v = i;
  assign o = v.u.a;
endmodule
