package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic [3:0] a, output logic y);
  assign y = a[P-1];
endmodule
