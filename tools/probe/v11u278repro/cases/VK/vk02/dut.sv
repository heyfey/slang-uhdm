// § elabPkgQualRefRhsPkgTs278
package p; parameter A = -5; endpackage
module top(input logic signed [7:0] i, output logic o);
  parameter K = p::A;
  assign o = i < K;
endmodule
