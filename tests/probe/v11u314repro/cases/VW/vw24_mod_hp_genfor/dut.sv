// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; logic [1:0] o [2]; for (genvar g = 0; g < 2; g++) begin : gf always_comb o[g] = a.v[g +: p::N]; end endmodule
