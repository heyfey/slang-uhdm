// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; function automatic logic [1:0] f(int k); return w[k +: p::N]; endfunction endmodule
