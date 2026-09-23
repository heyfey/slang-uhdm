// SIZE: ut_e [0:1][0:2]
package q2;
  typedef logic [1:0] ut_e;
  typedef struct packed { logic [3:0] pad; ut_e [0:1][0:2] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 12'h56A, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.m;
  assign o = V;
endmodule
