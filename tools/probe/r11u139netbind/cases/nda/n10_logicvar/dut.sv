// § ndaLeftmostLeafElab139
module top(input p, output y);
  logic l;
  assign l = p;
  wire w = l & p;
  wire x = p & l;
  assign y = w ^ x;
endmodule
