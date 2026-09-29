// § fwdPkgRefClassScopeSpan227
package p1;
  localparam int C = 1;
  localparam p2::e_t Q = C ? p2::E1 : (C ? p2::E2 : p2::E3);
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(output int o);
  assign o = p1::Q;
endmodule
