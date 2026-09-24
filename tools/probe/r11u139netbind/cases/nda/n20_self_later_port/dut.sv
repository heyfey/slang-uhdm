// § ndaLeftmostLeafElab139
module top(input p, output y, input late);
  wire w = late & p;
  assign y = w;
endmodule
