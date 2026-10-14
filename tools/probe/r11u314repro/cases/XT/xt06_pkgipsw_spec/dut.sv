// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
class c #(int W = 2); logic [7:0] w; function logic [1:0] f(int k); return w[k +: p::N]; endfunction endclass
module top; c #(3) h; endmodule
