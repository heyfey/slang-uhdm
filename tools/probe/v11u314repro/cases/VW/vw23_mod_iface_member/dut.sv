// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
interface ifc; logic [7:0] w; endinterface
module top; ifc u(); int k; logic [1:0] o; always_comb o = u.w[k +: p::N]; endmodule
