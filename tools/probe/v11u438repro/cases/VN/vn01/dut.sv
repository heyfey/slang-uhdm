// § ndaUnsizedRhsFreshLhs438
module sub #(parameter P = 0) (input [15:0] b, output y);
  wire w = b['h1 + P];
  assign y = w;
endmodule
module top(input [15:0] b, output y, z);
  sub #(.P(1)) u(.b(b), .y(y));
  sub #(.P(3)) v(.b(b), .y(z));
endmodule
