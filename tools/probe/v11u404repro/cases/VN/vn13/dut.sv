// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  sub s1(i, w);
  for (genvar k = 0; k < 1; k++) begin : g
    sub s2(.a(w), .b(y));
  end
endmodule
