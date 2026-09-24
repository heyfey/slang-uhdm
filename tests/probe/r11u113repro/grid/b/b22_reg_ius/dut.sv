package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  reg [P:0] x;
  always_comb x = i[5:0];
  assign o = x;
endmodule
