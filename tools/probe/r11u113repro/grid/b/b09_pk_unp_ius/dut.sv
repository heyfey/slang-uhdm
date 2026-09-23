package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x [2];
  assign x[0] = i[5:0];
  assign x[1] = i[5:0];
  assign o = x[1];
endmodule
