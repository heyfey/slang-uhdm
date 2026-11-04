// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top #(parameter int S = 1); logic [7:0] w; int k; logic [1:0] o; case (S) 1: begin : gc always_comb o = w[k +: p::N]; end default: ; endcase endmodule
