// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 5; endpackage
module m(output logic [7:0] o); localparam K = p::A; localparam L = K + 1; assign o = L; endmodule
