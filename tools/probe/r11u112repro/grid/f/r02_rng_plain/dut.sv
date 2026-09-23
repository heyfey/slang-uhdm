package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [5:0] i, output logic [5:0] o);
  logic [P:0] x;
  assign x = i;
  assign o = x;
endmodule
