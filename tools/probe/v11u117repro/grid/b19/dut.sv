// struct type in another package, IMPL in q2 + L1
package p0;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
endpackage
package q2; localparam p0::impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 }; endpackage
module top(output logic [1:0] o); localparam logic [1:0] V = q2::IMPL.cfg; assign o = V; endmodule
