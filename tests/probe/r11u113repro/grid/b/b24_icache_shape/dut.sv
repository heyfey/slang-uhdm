package pk; parameter int unsigned P = 1; parameter int unsigned Q = 2; endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 4) (input logic [1:0] i, output logic [1:0] o);
  logic [NUM_FB-1:0][P:0] x_d, x_q;
  assign x_d = {NUM_FB{i}};
  assign x_q = x_d;
  assign o = x_q[0];
endmodule
