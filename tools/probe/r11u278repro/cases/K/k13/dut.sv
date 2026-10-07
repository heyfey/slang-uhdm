// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 8'hFF; endpackage
module m; parameter K = p::A; endmodule
