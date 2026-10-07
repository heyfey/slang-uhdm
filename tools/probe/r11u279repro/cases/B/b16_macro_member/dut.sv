// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
`define MEM row_t [0:1] U;
  typedef struct packed { `MEM logic c; } impl_t;
endpackage
module top(output logic o);
  q2::impl_t v;
  assign o = ^v;
endmodule
