// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
typedef struct packed { logic [7:0] v; } a_t;
module c(input logic [1:0] i); endmodule
module top; a_t a; c u(.i(a.v[3 +: p::N])); endmodule
