package pk; parameter bit [7:0] P = 5; parameter bit [7:0] Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[5:0];
  assign o = x;
endmodule
