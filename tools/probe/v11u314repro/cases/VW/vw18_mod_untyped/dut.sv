// § pkgQualIpsWidthSpanQualifier314
package p; parameter N = 2; endpackage
module top; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: p::N]; endmodule
