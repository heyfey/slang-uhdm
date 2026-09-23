package pk; parameter int P = 2**2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[4:0];
  assign o = x;
endmodule
