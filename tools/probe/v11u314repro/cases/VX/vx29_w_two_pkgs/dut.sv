// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
package q; localparam int N = 1; endpackage
module top; logic [7:0] w; int k; logic [2:0] o; always_comb o = {w[k +: p::N], w[k +: q::N]}; endmodule
