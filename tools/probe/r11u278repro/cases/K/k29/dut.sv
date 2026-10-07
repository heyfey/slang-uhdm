// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module m(output logic [7:0] o); parameter K = p::A; assign o = {K{1'b1}}; endmodule
