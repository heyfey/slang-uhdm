// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; } in_t;
  typedef struct packed { in_t a; logic b; } out_t;
endpackage
module top(output logic o);
  q2::out_t v;
  assign o = ^v;
endmodule
