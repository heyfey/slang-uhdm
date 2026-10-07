// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 2; endpackage
module m(output logic [1:0] o); parameter K = p::A;
  for (genvar i = 0; i < K; i++) begin : g assign o[i] = 1'b0; end
endmodule
