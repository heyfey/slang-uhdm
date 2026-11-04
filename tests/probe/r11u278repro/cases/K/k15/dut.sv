// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m(output logic [31:0] o); parameter K = p::A; assign o = K; endmodule
