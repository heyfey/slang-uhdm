// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  function automatic int g(int a); return a; endfunction
  initial z = g((f(1)));
endmodule
