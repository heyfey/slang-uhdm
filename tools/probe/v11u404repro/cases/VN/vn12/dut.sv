// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  sub s1(i, w);
  if (1) begin : g
    assign y = w;
  end
endmodule
