// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter W2 = 2; endpackage
module mid import pk::*; #(parameter int unsigned N = 2) (input logic s, input logic [2:0] q [N], output logic [2:0] y [N]);
  for (genvar i = 0; i < N; i++) begin : g
    assign y[i] = {s, $clog2(W)};
  end
endmodule
module mid2 (input logic s, input logic [2:0] q [2], output logic [2:0] y [2]);
  mid u2 (.s(s), .q(q), .y(y));
endmodule
module top (input logic s, input logic [2:0] q [2], output logic [2:0] y [2]);
  mid2 u1 (.s(s), .q(q), .y(y));
endmodule
