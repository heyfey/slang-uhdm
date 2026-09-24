package pk; parameter int unsigned R = 3; parameter int unsigned P = R * 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[6:0];
  assign o = x;
endmodule
