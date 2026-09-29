// § fwdPkgRefClassScopeSpan227
package p1;
  function automatic int f(logic [7:0] w);
    return w[p2::E2:0];
  endfunction
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(input logic [7:0] i, output int o);
  assign o = p1::f(i);
endmodule
