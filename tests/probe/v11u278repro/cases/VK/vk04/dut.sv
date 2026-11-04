// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module top(output logic [7:0] o);
  parameter K = p::A + 0;
  assign o = K;
endmodule
