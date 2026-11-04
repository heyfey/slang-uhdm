// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; logic [1:0] o; always_comb o = w[3 +: p::N]; endmodule
