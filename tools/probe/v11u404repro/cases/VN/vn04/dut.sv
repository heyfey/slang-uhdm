// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i);
  sub s1(i, w);
  initial begin : blk
    int w;
    w = 1;
  end
endmodule
