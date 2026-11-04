// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module c(input logic [1:0] i); endmodule
module top; logic [7:0] w; c u(.i(w[3 +: p::N])); endmodule
