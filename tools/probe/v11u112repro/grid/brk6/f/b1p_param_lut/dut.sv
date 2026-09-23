package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; #(parameter logic [7:0] LUT = 8'hA5) (input logic [3:0][1:0] a, output logic y, output logic z);
  assign y = LUT[P-1];
  assign z = a[P-1][0];
endmodule
