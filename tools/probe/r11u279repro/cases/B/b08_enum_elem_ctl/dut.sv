// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic c; } impl_t;
endpackage
module top(output logic o);
  q2::impl_t v;
  assign o = ^v;
endmodule
