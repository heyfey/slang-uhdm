// § fwdPkgRefClassScopeSpan227
package p1;
  function automatic int f(int w);
    int s = 0;
    for (int i = 0; i < p2::E3; i++) s += w;
    return s;
  endfunction
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(input int i, output int o);
  assign o = p1::f(i);
endmodule
