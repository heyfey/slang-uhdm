// unsized '1 member + package-internal select road (L2 only)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: '1, cfg: 2'b11 };
  localparam logic [1:0] C0 = IMPL.cfg;
endpackage
module top(output logic [1:0] o); assign o = q2::C0; endmodule
