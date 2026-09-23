// BODY parameter (overridable, no port list) select, overridden
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module leaf(output logic [1:0] o); parameter logic [1:0] C = q2::IMPL.cfg; assign o = C; endmodule
module top(output logic [1:0] o); leaf #(.C(2'b01)) u(.o(o)); endmodule
