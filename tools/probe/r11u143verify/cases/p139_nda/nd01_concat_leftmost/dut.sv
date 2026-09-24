// § ndaLeftmostLeafElab139
// case nd01: a net declaration assignment whose left operand is a concatenation
module top(input logic [1:0] a, input logic [1:0] b, input logic [3:0] c, output logic [3:0] y);
  wire [3:0] w = {a, b} + c;
  assign y = w;
endmodule
