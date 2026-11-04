// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; parameter K = p::A + 1; endmodule
