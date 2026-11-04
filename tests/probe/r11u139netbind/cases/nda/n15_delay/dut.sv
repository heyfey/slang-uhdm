// § ndaLeftmostLeafElab139
module top(input p, input q, output y);
  wire #1 w = p;
  wire #1 x = p & q;
  assign y = w ^ x;
endmodule
