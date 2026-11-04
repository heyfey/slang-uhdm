// § memberSelCallIdxParenSpan312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; int k; logic [7:0] o; function automatic int g(int x); return x; endfunction
  always_comb o = ps.idx[g(k)];
endmodule
