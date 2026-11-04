// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [3:0] nib_t;
  typedef nib_t [0:1] row_t;
  typedef struct packed { row_t [0:2] U; logic c; } impl_t;
endpackage
module top(output logic o);
  q2::impl_t v;
  assign o = ^v;
endmodule
