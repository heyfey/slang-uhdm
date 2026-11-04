// § ndaUnsizedRhsFreshLhs438
module other(input [15:0] b, output y);
  wire w = b['h2];
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  wire w = b['h3];
  assign y = w;
endmodule
