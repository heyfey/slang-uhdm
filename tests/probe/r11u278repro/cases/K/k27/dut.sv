// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
module m #(parameter K = p::A) (output logic [31:0] o); assign o = K; endmodule
