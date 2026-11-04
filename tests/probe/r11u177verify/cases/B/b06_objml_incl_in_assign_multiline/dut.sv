// § ppOutputFile166 § ppOutputLine166
`include "defs.svh"
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z, output logic [7:0] w);
  assign y = a + `XW +
    a;
  assign z = a;
  assign w = a;
endmodule
