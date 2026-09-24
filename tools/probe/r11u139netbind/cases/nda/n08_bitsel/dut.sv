// § ndaLeftmostLeafElab139
module top(input [1:0] p, input q, output y);
  wire w = p[0];
  wire x = p[1] & q;
  assign y = w ^ x;
endmodule
