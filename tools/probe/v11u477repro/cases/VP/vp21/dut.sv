// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b, int c = 9); return a - b + c; endfunction
  initial z = (f(.b(2), .a(1)));
endmodule
