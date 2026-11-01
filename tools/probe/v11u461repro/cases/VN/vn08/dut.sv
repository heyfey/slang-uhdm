// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; logic [3:0] b; } u; logic [3:0] y; } s_t;
endpackage
module top(input p::s_t i, output logic [7:0] o);
  assign o = {i.u.a, i.y};
endmodule
