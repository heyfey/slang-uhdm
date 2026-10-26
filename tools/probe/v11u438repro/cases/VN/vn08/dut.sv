// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output y, z);
  wire w1 = b['h6], w2 = b['h7];
  assign y = w1;
  assign z = w2;
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
