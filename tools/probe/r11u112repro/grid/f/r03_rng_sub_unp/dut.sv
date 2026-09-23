package pk; parameter int unsigned P = 6; endpackage
module top import pk::*; (input logic [5:0] i, output logic [5:0] o);
  logic [P-1:0] x [2];
  assign x[0] = i;
  assign x[1] = i;
  assign o = x[1];
endmodule
