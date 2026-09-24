// § ndaLeftmostLeafElab139
module top #(parameter P = 1) (input [3:0] p, output [3:0] y);
  wire [3:0] w = P + p;
  wire [3:0] x = p + P;
  assign y = w ^ x;
endmodule
