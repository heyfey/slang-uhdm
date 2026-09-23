// SIZE: row_t [0:1]
package q2;
  typedef logic [2:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 18'h156A, cfg: 2'b11 };
endpackage
module top(output logic [17:0] o);
  localparam logic [17:0] V = q2::IMPL.m;
  assign o = V;
endmodule
