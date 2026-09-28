// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; endpackage
module top import pk::*; #(parameter int unsigned N = 2) (input logic [N-1:0] c, input logic s, input logic [2:0] q [N], output logic [2:0] y [N], output logic [2:0] z, output logic [7:0] m);
  if (N > 1) begin : g1
    logic [2:0] t;
    assign t = {s, W};
    assign y[0] = t;
  end
  if (N > 0) begin : g2
    logic [2:0] t;
    assign t = {2'b0, s};
    assign y[1] = t;
  end
endmodule
