package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter logic [3:0] L = 2; parameter bit B1 = 1'b1; typedef logic [3:0] n_t; parameter n_t N = 3; parameter byte BY = 2; endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 2) (input logic [NUM_FB-1:0] c, input logic s, t, input logic [2:0] q [NUM_FB], input logic [2:0] r [NUM_FB][4], output logic [2:0] y [NUM_FB], output logic [2:0] z [NUM_FB][4], output logic [7:0] m);
  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g
    assign y[fb] = q[fb] + $bits(W);
  end
  assign m = '0;
endmodule
