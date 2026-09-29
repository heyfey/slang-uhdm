// § fwdPkgRefConstSlotWhole227v
package p1;
  localparam p2::s_t P = '{
      a: '{p2::E2{64'h0, 64'h1}},
      x: p2::E1,
      y: 1
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
