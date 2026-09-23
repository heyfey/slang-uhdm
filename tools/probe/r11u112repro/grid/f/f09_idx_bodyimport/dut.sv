package pk; parameter int unsigned P = 2; endpackage
module top (input logic [3:0] a, output logic y);
  import pk::*;
  assign y = a[P-1];
endmodule
