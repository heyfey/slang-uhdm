// § topPkgMemberTdOfNamedElemShares279
package p1;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
package q2;
  typedef struct packed { p1::row_t [0:1] U; logic c; } impl_t;
endpackage
module top(output logic o);
  q2::impl_t v;
  assign o = ^v;
endmodule
