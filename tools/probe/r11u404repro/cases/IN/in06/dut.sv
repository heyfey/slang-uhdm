// § implicitNetDefLastRef404
module top(input a, input b);
  and (r1, a, b);
  buf (r3, a);
  buf g5(r5, a);
  not #2 (r4, a);
  pullup p1 (r7);
  sub s2 (a, r9);
  initial $display("%b %b %b %b %b %b", r1, r3, r4, r5, r7, r9);
endmodule
module sub(input i, output o); assign o = i; endmodule
