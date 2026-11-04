// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; int k; always_comb w[k +: p::N] = 2'b0; endmodule
