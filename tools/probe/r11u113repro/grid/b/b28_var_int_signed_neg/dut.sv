package pk; parameter int P = -1; parameter int Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [7:P] x;
  assign x = i;
  assign o = x;
endmodule
