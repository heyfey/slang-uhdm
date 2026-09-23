// enum member + doubled member + L1
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { e_t k; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ k: B, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [1:0] o); localparam logic [1:0] V = q2::IMPL.cfg; assign o = V; endmodule
