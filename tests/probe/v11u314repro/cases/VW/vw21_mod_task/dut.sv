// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module top; logic [7:0] w; task t(input int k); w[k +: p::N] = 0; endtask endmodule
