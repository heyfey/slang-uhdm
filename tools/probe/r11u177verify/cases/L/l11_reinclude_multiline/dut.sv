// § ppReincludeSplice166 § ppOutputInclLine166
`include "inc.svh"
module top(input logic a, input logic b, output logic y, output logic z);
`include "inc.svh"
  assign y = `TWO(a, b);
`include "inc.svh"
  assign z = a;
endmodule
