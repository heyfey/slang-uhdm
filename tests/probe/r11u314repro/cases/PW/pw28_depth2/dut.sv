// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module leaf; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: p::N]; endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule
