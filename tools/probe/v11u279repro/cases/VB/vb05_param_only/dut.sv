// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic b; } impl_t;
  localparam impl_t DEF = '0;
endpackage
module top(output logic [12:0] o);
  assign o = q2::DEF;
endmodule
