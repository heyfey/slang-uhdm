// § ndaLeftmostLeafElab139
// case nd03: a net declaration assignment whose left operand is a size cast
module top(input logic [1:0] a, input logic [3:0] b, output logic [3:0] y);
  wire [3:0] w = 4'(a) + b;
  assign y = w;
endmodule
