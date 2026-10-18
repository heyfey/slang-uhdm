// § implicitNetDefLastRef404
module top(input a, input b);
  assign x = a & b;
  wire y = x;
  sub s1(a, p);
  sub s2(p, q);
  and g1(r, a, b);
  wire z = r | q;
  initial $display("%b %b %b", p, q, r);
endmodule
module sub(input i, output o);
  assign o = i;
endmodule
