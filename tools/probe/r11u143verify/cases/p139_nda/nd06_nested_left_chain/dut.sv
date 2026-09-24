// § ndaLeftmostLeafElab139
// case nd06: a nested binary left chain, three leaves
module top(input logic [3:0] a, input logic [3:0] b, input logic [3:0] c, output logic [7:0] y);
  wire [7:0] w = a * b + c;
  assign y = w;
endmodule
