// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 2; endpackage
module c #(parameter K = p::A) (output logic [K-1:0] o); assign o = '0; endmodule
module m(output logic [1:0] o1, o2); c u1(.o(o1)); c u2(.o(o2)); endmodule
