// L1 + 64-bit member exactly (boundary of the fence)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [63:0] w; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ w: 64'h0123456789ABCDEF, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [1:0] o); localparam logic [1:0] V = q2::IMPL.cfg; assign o = V; endmodule
