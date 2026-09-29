// § fwdPkgRefClassScopeSpan227
package p1;
  localparam p2::s_t P = '{a: {4{64'h0}}, x: p2::E1, y: 1}, R = '{a: {4{64'h0}}, x: p2::E0, y: 2};
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
endpackage
module top(output int o);
  assign o = p1::P.y;
endmodule
