// (r11u191 split real port) a shortreal redeclaration and an input redeclared real, instantiated by a Verilog-style top
module sub(a, d);
  input a;
  output d;
  real a;
  shortreal d;
  always @(*) d = a;
endmodule
module top(x, y);
  input x;
  output y;
  sub u(.a(x), .d(y));
endmodule
