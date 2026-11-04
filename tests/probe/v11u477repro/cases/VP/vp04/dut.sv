// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b = 5, int c = 6); return a + b + c; endfunction
  initial z = (f(1, , 3));
endmodule
