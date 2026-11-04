// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output y, z);
  tri t = b['h4];
  wand a = b['h5];
  assign y = t;
  assign z = a;
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
