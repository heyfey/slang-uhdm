// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  initial z = (f(.a(1)));
endmodule
