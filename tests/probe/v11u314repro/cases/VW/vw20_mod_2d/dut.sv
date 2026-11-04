// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w [4]; int k; int i; logic [1:0] o; always_comb o = w[i][k +: p::N]; endmodule
