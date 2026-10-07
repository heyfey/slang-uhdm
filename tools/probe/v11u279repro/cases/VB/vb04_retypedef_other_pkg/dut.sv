// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
endpackage
package q3;
  typedef q2::impl_t impl2_t;
endpackage
module top(output logic o);
  q3::impl2_t v;
  assign o = ^v;
endmodule
