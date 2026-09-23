package pk; parameter int unsigned W = $clog2(4); parameter int unsigned WL = 2; parameter int S = 2; parameter U = 2; parameter logic [3:0] L = 2; endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 2) (input logic [NUM_FB-1:0][3:0] q2, input logic s, output logic y [NUM_FB], output logic z);
  logic [NUM_FB-1:0][3:0] o2;
  assign o2[1][W] = s;
  assign z = o2[1][0];
  assign y[0] = s;
  assign y[1] = s;
endmodule
