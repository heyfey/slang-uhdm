// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b); return a + b; endfunction
  initial z = (f(1, 2));
endmodule
