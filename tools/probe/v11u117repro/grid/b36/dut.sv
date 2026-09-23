// L1 + 65-bit member (fence must decline)
package q2;
  typedef struct packed { logic [64:0] w; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ w: 65'h1, cfg: 2'b11 };
endpackage
module top(output logic [1:0] o); localparam logic [1:0] V = q2::IMPL.cfg; assign o = V; endmodule
