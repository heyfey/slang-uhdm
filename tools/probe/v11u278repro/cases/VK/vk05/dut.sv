// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
module top(output logic [7:0] o);
  if (1) begin : g
    localparam K = p::A;
    assign o = K;
  end
endmodule
