package pk; parameter int P = -2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [5:P] x;
  assign x = i;
  assign o = x;
endmodule
