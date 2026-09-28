// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; endpackage
module top import pk::*; #(parameter int unsigned N = 2, parameter int D = 1) (input logic [N-1:0] c, input logic s, input logic [2:0] q [N], output logic [2:0] y [N], output logic [2:0] z, output logic [7:0] m);
  if (N > 1) begin : g
    assign y[0] = $clog2(W + 1);
    assign y[1] = {s, W + 1};
  end
endmodule
