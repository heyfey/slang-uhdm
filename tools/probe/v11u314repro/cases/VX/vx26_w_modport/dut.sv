// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
typedef struct packed { logic [7:0] v; } a_t;
interface ifc; a_t a; modport m(input a); endinterface
module c(ifc.m u); int k; logic [1:0] o; always_comb o = u.a.v[k +: p::N]; endmodule
module top; ifc u(); c cc(.u(u)); endmodule
