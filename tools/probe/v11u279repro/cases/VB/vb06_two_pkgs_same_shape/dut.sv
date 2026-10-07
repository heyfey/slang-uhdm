// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
endpackage
package q4;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
endpackage
module top(output logic o, output logic o2);
  q2::impl_t v; q4::impl_t w;
  assign o = ^v; assign o2 = ^w;
endmodule
