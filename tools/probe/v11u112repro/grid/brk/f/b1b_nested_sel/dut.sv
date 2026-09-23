package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic [3:0] a, input logic [1:0] b [4], output logic y);
  assign y = a[b[P-1]];
endmodule
