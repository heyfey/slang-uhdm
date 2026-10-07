// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; parameter signed K = p::A; endmodule
