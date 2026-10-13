// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; localparam int P = 1; a_t a; int ix[4]; always_comb a.v[ix[P] +: 2] = 0; endmodule
