// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3'b101; endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  parameter K = p::A;
  assign o = i[K:0];
endmodule
