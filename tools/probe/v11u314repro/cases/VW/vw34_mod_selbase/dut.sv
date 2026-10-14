// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; int ix[4]; int k; logic [1:0] o; always_comb o = w[ix[k] +: p::N]; endmodule
