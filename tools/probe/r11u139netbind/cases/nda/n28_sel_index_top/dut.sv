// § ndaLeftmostLeafElab139
module top(input [1:0] idx, input [3:0] v, output y);
  wire [1:0] j = idx;
  wire w = v[j];
  assign y = w;
endmodule
