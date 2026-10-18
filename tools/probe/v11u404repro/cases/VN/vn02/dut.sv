// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i);
  sub s1(i, b);
  sub s2(b, x);
  initial $display(s1.b);
endmodule
