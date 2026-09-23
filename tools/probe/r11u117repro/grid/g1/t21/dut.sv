// row_t[0:1] member, two-member-deep: typedef'd member NOT selected, plain v selected, plain v first
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] v; row_t [0:1] m; } impl_t;
  localparam impl_t IMPL = '{ v: 4'h9, m: 12'h56A };
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] V = q2::IMPL.v;
  assign o = V;
endmodule
