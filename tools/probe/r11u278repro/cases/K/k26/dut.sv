// § elabPkgQualRefRhsPkgTs278
package p; localparam A = 13; endpackage
module m; import p::A; localparam K = p::A; endmodule
