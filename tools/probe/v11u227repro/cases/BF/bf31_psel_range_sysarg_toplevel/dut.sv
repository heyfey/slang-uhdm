// § fwdPkgRefConstSlotWhole227v
package p1;
  localparam logic [7:0] W = 8'hA5;
  localparam p2::e_t Q = p2::E1;
  localparam int Y = $bits(W[p2::E3:0]);
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(output int o);
  assign o = p1::Y + p1::Q;
endmodule
