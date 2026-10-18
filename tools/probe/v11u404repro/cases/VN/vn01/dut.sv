// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i);
  sub s1(i, w);
  function automatic int f(int w); return w + 1; endfunction
  initial $display(f(3));
endmodule
