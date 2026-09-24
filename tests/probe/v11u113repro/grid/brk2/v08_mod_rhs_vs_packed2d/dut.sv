package pk; parameter int unsigned P = 4; endpackage
module top import pk::*; (input logic [1:0][3:0] a, input logic k, output logic y);
  assign y = ~a[k][P-1];
endmodule
