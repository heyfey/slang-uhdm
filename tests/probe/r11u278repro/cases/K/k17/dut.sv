// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module c; parameter K = p::A; endmodule
module m; c u1(); c u2(); endmodule
