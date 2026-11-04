// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
`define WN p::N
module top; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: `WN]; endmodule
