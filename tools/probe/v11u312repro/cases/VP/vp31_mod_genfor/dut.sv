// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a [2]; int ix[4]; for (genvar g = 0; g < 2; g++) begin : gl always_comb a[g].v[ix[g] +: 2] = 0; end endmodule
