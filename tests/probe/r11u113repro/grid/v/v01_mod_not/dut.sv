package pk; parameter int unsigned P = 4; parameter int S = 4; parameter U = 4; endpackage
module top import pk::*; (input logic [3:0] a [2], input logic k, output logic y, output logic z [2]);
  assign y = ~a[k][P-1];
  assign z[0] = 1'b0;
  assign z[1] = 1'b0;
endmodule
