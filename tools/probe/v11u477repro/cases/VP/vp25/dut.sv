// § parenCallWrittenArgs477
module top(input int a, output int z);
  function automatic int f(int x, int y = 2); return x * y; endfunction
  assign z = (f(a)) ? (f(.x(a))) : (f(a, 3));
endmodule
