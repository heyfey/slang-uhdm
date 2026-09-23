// row_t[0:3] member (Surelog 72b) + scoped cont-assign read
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:3] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 24'h56A56A, cfg: 2'b11 };
endpackage
module top(output logic [23:0] o);
  assign o = q2::IMPL.m;
endmodule
