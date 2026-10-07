// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 'h1_0000_0000; endpackage
module top(output logic [63:0] o);
  parameter K = p::A;
  assign o = K;
endmodule
