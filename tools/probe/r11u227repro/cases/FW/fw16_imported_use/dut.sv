// § fwdPkgRefClassScopeSpan227
package p1;
  localparam p2::s_t P = '{
      a: {4{64'h0}},
      x: p2::E1,
      y: 7
  };
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
endpackage
module top(output int o);
  import p1::*;
  sub #(.W(P.y)) u();
  assign o = P.y;
endmodule
module sub #(parameter int W = 1) ();
  logic [W-1:0] v;
endmodule
