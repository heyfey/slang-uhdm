// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 1'b1; endpackage
module top(input logic a, output logic o);
  parameter K = p::A;
  assign o = a & K;
endmodule
