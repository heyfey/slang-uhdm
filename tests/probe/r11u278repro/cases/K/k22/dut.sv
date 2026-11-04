// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
package q; parameter A2 = p::A; endpackage
module m; parameter K = q::A2; endmodule
