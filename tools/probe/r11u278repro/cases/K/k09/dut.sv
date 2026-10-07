// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module c #(parameter K = p::A) (); endmodule
module m; c #(.K(5)) u(); endmodule
