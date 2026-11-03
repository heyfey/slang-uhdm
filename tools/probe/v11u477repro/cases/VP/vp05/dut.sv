// § parenCallWrittenArgs477
module top(input int a, output int z);
  function automatic int f(int x, int y = 2); return x * y; endfunction
  assign z = (f(a)) + 1;
endmodule
