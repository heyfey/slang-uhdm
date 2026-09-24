package pk; parameter int unsigned R = 5; parameter int unsigned P = R; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[5:0];
  assign o = x;
endmodule
