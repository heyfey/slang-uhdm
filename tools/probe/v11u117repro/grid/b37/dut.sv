// L1 with plain (non-doubled) members only, whole-member read of a vector
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); localparam logic [11:0] V = q2::IMPL.m; assign o = V; endmodule
