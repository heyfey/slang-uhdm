// § ndaLeftmostLeafElab139
module top(input [1:0] idx, input [7:0] v, output [1:0] y);
  wire [1:0] w = v[idx*2 +: 2];
  assign y = w;
endmodule
