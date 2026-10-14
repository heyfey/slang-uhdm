// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
module c #(parameter int K = 1) (input logic [7:0] w, output logic [1:0] o); always_comb o = w[K +: p::N]; endmodule
module top; logic [7:0] w; logic [1:0] o; c #(.K(3)) u(.w(w), .o(o)); endmodule
