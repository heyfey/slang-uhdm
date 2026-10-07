// § elabPkgQualRefRhsPkgTs278
package p; parameter logic [7:0] A = 13; endpackage
module m; parameter K = p::A; endmodule
