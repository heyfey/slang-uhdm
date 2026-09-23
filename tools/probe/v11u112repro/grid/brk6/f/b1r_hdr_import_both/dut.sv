package pk; parameter int unsigned P = 2; parameter int unsigned Q = 1; endpackage
module top import pk::*; (input logic [7:0] a, output logic y);
  assign y = a[P+Q] | a[P-Q] & a[P*Q];
endmodule
