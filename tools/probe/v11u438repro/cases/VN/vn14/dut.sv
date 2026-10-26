// § ndaUnsizedRhsFreshLhs438
module other(input [15:0] b, output y);
  wire w = b['h2];
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  other u(.b(b), .y(y));
endmodule
module spare(input [15:0] b, output y);
  wire w = b['h4];
  assign y = w;
endmodule
