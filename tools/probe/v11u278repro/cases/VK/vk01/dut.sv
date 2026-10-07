// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 40'hF_FFFF_FFFF; endpackage
module top(output logic [63:0] o);
  parameter K = p::A;
  assign o = K;
endmodule
