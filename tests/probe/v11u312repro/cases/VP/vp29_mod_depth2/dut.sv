// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module sub; a_t a; int ix[4]; int k; always_comb a.v[ix[k] +: 2] = 0; endmodule
module mid; sub u(); endmodule
module top; mid m(); endmodule
