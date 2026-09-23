package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic x [P:0];
  assign x[0] = i[0];
  assign o = x[0];
endmodule
