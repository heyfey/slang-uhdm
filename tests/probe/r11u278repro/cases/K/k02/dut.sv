// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; parameter int K = p::A; endmodule
