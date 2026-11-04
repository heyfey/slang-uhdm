// § pkgQualIpsWidthSpanQualifier314
class pc #(int N = 2); endclass
module top; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: pc#(2)::N]; endmodule
