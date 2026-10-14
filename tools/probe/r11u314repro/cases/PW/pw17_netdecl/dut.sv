// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; int k; wire [1:0] o = w[k +: p::N]; endmodule
