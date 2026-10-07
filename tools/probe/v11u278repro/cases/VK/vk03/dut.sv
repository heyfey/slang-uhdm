// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 32'hFFFF_FFFF; endpackage
module top(output logic [63:0] o);
  localparam K = p::A;
  assign o = K + 1;
endmodule
