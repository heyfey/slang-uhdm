// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; localparam K = p::A; endmodule
