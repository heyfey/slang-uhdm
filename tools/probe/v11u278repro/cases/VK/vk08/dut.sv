// § elabPkgQualRefRhsPkgTs278
package p; parameter B = 64'd5; parameter A = B; endpackage
module top(output logic [63:0] o);
  parameter K = p::A;
  assign o = K;
endmodule
