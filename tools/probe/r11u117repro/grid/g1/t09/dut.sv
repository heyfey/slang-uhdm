// typedef ut_e [0:1][0:1] mm_t; member mm_t
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:1][0:1] mm_t;
  typedef struct packed { logic [3:0] pad; mm_t m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 8'h5A, cfg: 2'b11 };
endpackage
module top(output logic [7:0] o);
  localparam logic [7:0] V = q2::IMPL.m;
  assign o = V;
endmodule
