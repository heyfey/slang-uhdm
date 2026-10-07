// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module top(input logic [7:0] i [4], output logic [7:0] o);
  parameter K = p::A;
  logic [K:0] w;
  assign w = '1;
  assign o = i[K] + w;
endmodule
