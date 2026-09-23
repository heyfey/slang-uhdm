// default: pattern + package-internal select (L2 only road)
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ m: 12'h56A, default: '0 };
  localparam logic [1:0] C0 = IMPL.cfg;
endpackage
module top(output logic [1:0] o); assign o = q2::C0; endmodule
