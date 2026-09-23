// typedef ut_e al_t (no dims); member al_t [0:2]
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e al_t;
  typedef struct packed { logic [3:0] pad; al_t [0:2] m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 6'h2A, cfg: 2'b11 };
endpackage
module top(output logic [5:0] o);
  localparam logic [5:0] V = q2::IMPL.m;
  assign o = V;
endmodule
