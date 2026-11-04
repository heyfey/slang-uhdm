// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a = 1, int b = 5); return a + b; endfunction
  initial z = (f(.b(2)));
endmodule
