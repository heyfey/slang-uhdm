// § ndaLeftmostLeafElab139
module top(input s, input p, input q, output y);
  wire w = s ? p : q;
  assign y = w;
endmodule
