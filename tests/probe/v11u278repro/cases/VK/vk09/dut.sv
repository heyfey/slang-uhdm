// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module m #(parameter K = p::A) (output logic [7:0] o); assign o = K; endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
  m a(o1);
  m #(.K(9)) b(o2);
endmodule
