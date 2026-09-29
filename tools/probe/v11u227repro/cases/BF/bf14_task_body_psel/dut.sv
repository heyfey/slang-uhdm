// § fwdPkgRefClassScopeSpan227
package p1;
  task automatic t(input logic [7:0] w, output int r);
    r = w[p2::E2:0];
  endtask
endpackage
package p2;
  localparam int K = 5;
  typedef enum {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0][63:0] a; e_t x; int y; } s_t;
  typedef struct packed { logic [7:0] b; int y; } t_t;
endpackage
module top(input logic [7:0] i, output int o);
  always_comb p1::t(i, o);
endmodule
