// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i);
  sub s1(i, w);
  task t; reg w; w = 1'b1; endtask
  initial t;
endmodule
