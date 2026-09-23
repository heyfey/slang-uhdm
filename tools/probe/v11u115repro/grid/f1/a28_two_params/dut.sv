package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter logic [3:0] L = 2; parameter bit B1 = 1'b1; typedef logic [3:0] n_t; parameter n_t N = 3; parameter byte BY = 2; endpackage
module sub import pk::*; #(parameter int unsigned N = 2) (input logic s, output logic [2:0] y [N]);
  for (genvar fb = 0; fb < N; fb++) begin : g
    assign y[fb] = {{W{1'b0}}, s};
  end
endmodule
module top (input logic s, output logic [2:0] a [2], output logic [2:0] b [3]);
  sub #(2) u0 (.s(s), .y(a));
  sub #(3) u1 (.s(s), .y(b));
endmodule
