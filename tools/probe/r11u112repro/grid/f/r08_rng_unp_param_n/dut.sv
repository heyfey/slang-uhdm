package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; #(parameter int unsigned N = 2) (input logic [5:0] i, output logic [5:0] o);
  logic [P:0] x [N];
  assign x[0] = i;
  assign x[1] = i;
  assign o = x[1];
endmodule
