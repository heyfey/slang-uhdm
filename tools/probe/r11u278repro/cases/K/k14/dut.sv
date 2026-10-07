// § elabPkgQualRefRhsPkgTs278
package p; parameter B = 4; parameter A = B; endpackage
module m; parameter K = p::A; endmodule
