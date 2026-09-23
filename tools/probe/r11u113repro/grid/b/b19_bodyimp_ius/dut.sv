package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top (input logic [7:0] i, output logic [7:0] o);
  import pk::*;
  logic [P:0] x;
  assign x = i[5:0];
  assign o = x;
endmodule
