package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [1:0][P:0] x;
  assign x = {i[5:0], i[5:0]};
  assign o = x[1];
endmodule
