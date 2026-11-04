// § pkgQualIpsWidthSpanQualifier314
module top; localparam int N = 2; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: N]; endmodule
