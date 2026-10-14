// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; logic [1:0] o [2]; for (genvar g = 0; g < 2; g++) begin : gf assign o[g] = w[g +: p::N]; end endmodule
