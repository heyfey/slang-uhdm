package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic [7:0] a, output logic y, output logic z);
  wire w = a[P-1];
  assign y = w;
  assign z = $unsigned(a[P+1]);
endmodule
