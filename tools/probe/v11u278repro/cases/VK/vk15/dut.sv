// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module top(output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam K = p::A + i;
    localparam J = p::A;
    assign o[i] = K + J;
  end
endmodule
