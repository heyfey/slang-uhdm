// § pkgQualIpsWidthSpanQualifier314
localparam int UN = 2;
module top; logic [7:0] w; int k; logic [1:0] o; always_comb o = w[k +: $unit::UN]; endmodule
