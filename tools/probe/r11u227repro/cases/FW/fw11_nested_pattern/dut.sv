// § fwdPkgRefClassScopeSpan227
package p1;
  typedef struct packed { p2::e_t x; int y; } in_t;
  typedef struct packed { logic [3:0][63:0] a; in_t s; } o_t;
  localparam o_t P = '{
      a: {4{64'h0}},
      s: '{x: p2::E1, y: 3}
  };
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
endpackage
module top(output int o);
  assign o = p1::P.s.y;
endmodule
