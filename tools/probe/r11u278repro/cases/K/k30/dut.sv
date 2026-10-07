// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module m(output logic [1:0] o, input logic [7:0] w); parameter K = p::A; assign o = w[K -: 2]; endmodule
