// struct elem typedef: typedef e_t [0:2] r_t; member r_t
package q2;
  typedef struct packed { logic a; logic b; } e_t;
  typedef e_t [0:2] r_t;
  typedef struct packed { logic [3:0] pad; r_t m; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, m: 6'h2A, cfg: 2'b11 };
endpackage
module top(output logic [5:0] o);
  localparam logic [5:0] V = q2::IMPL.m;
  assign o = V;
endmodule
