// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; import p::*; parameter K = A; endmodule
