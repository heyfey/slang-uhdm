// § fwdPkgRefClassScopeSpan227
package p1;
  function automatic int f();
    return p2::K;
  endfunction
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
endpackage
module top(output int o);
  assign o = p1::f();
endmodule
