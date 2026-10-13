// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; int k; logic [1:0] o; always_comb o = a.v[ix[k] +: 2]; endmodule
