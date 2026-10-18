// § implicitNetDefLastRef404
module top(input a, input b);
  and g1(r1, a, b);
  or g2(r2, a, b);
  buf g3(r3, a);
  not g4(r4, a);
  buf g5(r5, r6, a);
  pullup (r7);
  initial $display("%b %b %b %b %b %b %b", r1, r2, r3, r4, r5, r6, r7);
endmodule
