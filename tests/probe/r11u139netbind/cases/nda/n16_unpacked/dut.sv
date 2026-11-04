// § ndaLeftmostLeafElab139
module top(input p, output y);
  wire a [1:0];
  assign a[0] = p;
  assign a[1] = p;
  wire w = a[0];
  assign y = w;
endmodule
