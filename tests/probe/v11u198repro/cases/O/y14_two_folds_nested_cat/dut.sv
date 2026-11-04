// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; endpackage
module top import pk::*; #(parameter int unsigned N = 2) (input logic [N-1:0] c, input logic s, input logic [2:0] q [N], output logic [2:0] y [N], output logic [2:0] z, output logic [7:0] m);
  for (genvar i = 0; i < N; i++) begin : g
    assign y[i] = {{s, W[0]}, S[0]};
  end
endmodule
