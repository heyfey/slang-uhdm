// § ppOutputFile166 § ppOutputLine166
`include "defs.svh"
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z, output logic [7:0] w);
  localparam int K = `XW + 1;
  localparam int L = 5;
  assign y = a + K;
  assign z = a + L;
  assign w = a;
endmodule
