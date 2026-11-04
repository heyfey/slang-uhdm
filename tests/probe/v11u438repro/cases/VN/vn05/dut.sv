// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output y);
  wire #2 w = b['h3];
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
