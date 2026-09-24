// § ndaLeftmostLeafElab139
// case nd07: a logical or whose left operand is a logical not
module top(input logic a, input logic b, output logic y);
  wire w = !a || b;
  assign y = w;
endmodule
