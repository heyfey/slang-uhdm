// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; parameter [7:0] K = p::A; endmodule
