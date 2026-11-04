// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  and (w, i, i);
  sub s1(i, v);
  assign y = w | v;
  always @(v) $display(v);
endmodule
