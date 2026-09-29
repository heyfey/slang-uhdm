// § fwdPkgRefClassScopeSpan227
package p1;
  localparam logic [7:0] W = 8'hA5;
  localparam p2::s_t P = '{
      a: {4{64'h0}},
      x: p2::E1,
      y: $countones(W[p2::E3:0])
  };
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(output int o);
  assign o = p1::P.y;
endmodule
