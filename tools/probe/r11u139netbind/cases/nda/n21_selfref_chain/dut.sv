// § ndaLeftmostLeafElab139
module top(input p, output y);
  wire a = p;
  wire b = a;
  wire c = b & a;
  assign y = c;
endmodule
