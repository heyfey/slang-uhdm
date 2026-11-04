// § ndaUnsizedRhsFreshLhs438 (control: a sized index)
module sub(input [15:0] b, output y);
  wire w = b[3];
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
