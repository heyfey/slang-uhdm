// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
endpackage
module top(input q2::impl_t v, output logic [1:0] o);
  assign o = v.U[1][2];
endmodule
