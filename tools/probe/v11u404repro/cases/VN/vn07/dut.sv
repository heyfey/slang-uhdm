// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  sub s1(i, w);
  sub s2(.a(w), .b(y));
  sub s3(i, z);
  nand (q, z, i);
  or o1 (r, z, q);
endmodule
