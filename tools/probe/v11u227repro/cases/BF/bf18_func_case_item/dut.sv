// § fwdPkgRefClassScopeSpan227
package p1;
  function automatic int f(p2::e_t w);
    case (w)
      p2::E1: return 3;
      default: return 0;
    endcase
  endfunction
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(input int i, output int o);
  assign o = p1::f(p2::e_t'(i));
endmodule
