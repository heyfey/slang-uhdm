// § pkgQualIpsWidthSpanQualifier314
package p; typedef logic [1:0] t2; localparam t2 N = 2; endpackage
module top; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: p::N]; endmodule
