package pk; parameter bit P = 1; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[1:0];
  assign o = x;
endmodule
