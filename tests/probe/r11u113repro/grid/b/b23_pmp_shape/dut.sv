package pk; parameter int unsigned P = 33; parameter int unsigned Q = 2; endpackage
module top import pk::*; #(parameter int unsigned N = 2) (input logic [33:0] i, output logic [33:0] o);
  logic [P:0] x [N];
  for (genvar r = 0; r < N; r++) begin : g_r
    assign x[r] = i;
  end
  assign o = x[1];
endmodule
