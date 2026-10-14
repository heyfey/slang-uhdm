// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; function automatic logic [1:0] f(logic [7:0] w, int k); return w[k +: p::N]; endfunction endpackage
module top; endmodule
