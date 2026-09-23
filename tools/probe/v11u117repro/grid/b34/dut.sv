// two package params, only one selected; other shares the type (L1 per param)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
  localparam impl_t IMPL2 = '{ pad: 4'h3, m: 12'h123, cfg: 2'b01 };
endpackage
module top(output logic [17:0] o); localparam logic [1:0] V = q2::IMPL.cfg; assign o = {q2::IMPL2, V}; endmodule
