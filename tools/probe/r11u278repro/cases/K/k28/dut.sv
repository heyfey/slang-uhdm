// § elabPkgQualRefRhsPkgTs278
`define PA p::A
package p; parameter A = 13; endpackage
module m; parameter K = `PA; endmodule
