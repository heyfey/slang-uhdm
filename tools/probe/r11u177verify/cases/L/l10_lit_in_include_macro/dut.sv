// § ppBasedLitWsAfter166 § ppOutputInclLine166
`include "inc.svh"
module top(input logic [7:0] a, output logic [7:0] y, output logic [3:0] z);
  assign y = a & `MASK;
  assign z = a[3:0] + `K(4);
endmodule
