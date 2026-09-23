// $bits(q2::IMPL.m) in a module localparam
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [31:0] o);
  localparam int W = $bits(q2::IMPL.m);
  assign o = W;
endmodule
