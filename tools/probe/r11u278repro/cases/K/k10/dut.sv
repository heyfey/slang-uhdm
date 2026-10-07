// § elabPkgQualRefRhsPkgTs278
package p; localparam A = 13; endpackage
module m; parameter K = (p::A); endmodule
