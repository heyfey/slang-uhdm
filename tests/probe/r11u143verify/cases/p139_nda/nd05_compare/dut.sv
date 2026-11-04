// § ndaLeftmostLeafElab139
// case nd05: a net declaration assignment with an equality operation
module top(input logic [3:0] a, input logic [3:0] b, output logic y);
  wire w = a == b;
  assign y = w;
endmodule
