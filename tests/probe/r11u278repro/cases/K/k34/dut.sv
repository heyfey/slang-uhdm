// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 5; endpackage
module m(output logic [7:0] o); parameter K = p::A; logic [7:0] w = K; assign o = w; endmodule
