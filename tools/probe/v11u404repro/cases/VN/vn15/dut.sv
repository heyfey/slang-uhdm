// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  sub s1(i, w);
  always_comb begin
    automatic logic w2 = w;
  end
  assign y = w;
endmodule
