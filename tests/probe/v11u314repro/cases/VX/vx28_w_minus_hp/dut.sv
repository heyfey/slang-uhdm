// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int k; logic [1:0] o; always_comb o = a.v[k -: p::N]; endmodule
