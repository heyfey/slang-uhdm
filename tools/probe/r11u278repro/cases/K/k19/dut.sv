// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m; if (1) begin : g localparam K = p::A; end endmodule
