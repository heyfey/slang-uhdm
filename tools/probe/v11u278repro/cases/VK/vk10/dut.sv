// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module top(output logic [7:0] o);
  import p::*;
  localparam A = 4;
  parameter K = p::A;
  assign o = K + A;
endmodule
