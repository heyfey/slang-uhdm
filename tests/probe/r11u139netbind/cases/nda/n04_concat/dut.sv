// § ndaLeftmostLeafElab139
module top(input p, input q, output [1:0] y);
  wire [1:0] w = {p, q};
  assign y = w;
endmodule
