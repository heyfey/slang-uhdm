// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
endpackage
module sub(input q2::impl_t i, output logic o); assign o = ^i; endmodule
module top(output logic o);
  q2::impl_t v;
  sub s(.i(v), .o(o));
endmodule
