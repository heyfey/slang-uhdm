package pk; parameter int unsigned W = $clog2(4); parameter int unsigned WL = 2; parameter int S = 2; parameter U = 2; parameter logic [3:0] L = 2; endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 2) (input logic [NUM_FB-1:0][3:0] q2, input logic s, output logic y [NUM_FB], output logic z);
  logic [NUM_FB-1:0][3:0] o2;
  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g
    assign o2[fb][W] = s;
    assign y[fb] = o2[fb][0];
  end
  assign z = s;
endmodule
