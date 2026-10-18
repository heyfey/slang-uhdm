// § implicitNetDefLastRef404
module sub(input a, output b); assign b = a; endmodule
module top(input i, output y);
  and (w, i, i);
  sub s1(w, y);
  function automatic logic f(logic w); return w; endfunction
  assign v = f(w);
endmodule
