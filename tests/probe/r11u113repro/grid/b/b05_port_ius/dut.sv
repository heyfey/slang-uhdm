package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module top import pk::*; (input logic [P:0] i, output logic [7:0] o);
  assign o = i;
endmodule
