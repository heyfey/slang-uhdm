package pk; parameter logic [3:0] P = 2; endpackage
module top import pk::*; (input logic [3:0] a, output logic y);
  assign y = a[P-1];
endmodule
