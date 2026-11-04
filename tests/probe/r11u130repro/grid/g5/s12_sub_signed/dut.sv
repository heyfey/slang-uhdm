// § netSigningTsSpan130
module sub;
  wire signed [5:0] a;
  assign a = 6'd1;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
