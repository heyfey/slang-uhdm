// § ppOutputLine166 § ppOutputInclLine166
`include "inc1.svh"
module top(input logic s, input logic [3:0] a, input logic [3:0] b, output logic [3:0] y, output logic [3:0] w);
  assign y = `WRAP(s, a, b);
  assign w = `SEL(s,
                  b, a);
endmodule
