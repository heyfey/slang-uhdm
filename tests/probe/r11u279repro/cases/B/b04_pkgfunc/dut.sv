// § topPkgMemberTdOfNamedElemShares279
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { row_t [0:1] U; logic c; } impl_t;
  function automatic impl_t f(input logic [12:0] x); return impl_t'(x); endfunction
endpackage
module top(input logic [12:0] i, output logic [12:0] o);
  assign o = q2::f(i);
endmodule
