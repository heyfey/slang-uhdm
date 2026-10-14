// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
class c; logic [7:0] w; int k; function logic [1:0] f(); return w[k +: p::N]; endfunction endclass
module top; endmodule
