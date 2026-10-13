// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int k; function automatic int g(int x); return x; endfunction always_comb a.v[g(k) +: 2] = 0; endmodule
