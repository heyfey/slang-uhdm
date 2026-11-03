// § parenCallWrittenArgs477
module top(output int z);
  task automatic t(input int a, output int r, input int b = 4); r = a + b; endtask
  function automatic int f(int a, int b = 5); return a + b; endfunction
  initial begin if ((f(1)) > 2) t(1, z); end
endmodule
