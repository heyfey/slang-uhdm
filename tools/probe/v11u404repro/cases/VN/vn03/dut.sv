// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i);
  sub s1(i, w);
  if (1) begin : g
    wire w;
    assign w = 1'b0;
  end
endmodule
