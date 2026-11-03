// § parenCallWrittenArgs477
module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  localparam int L = (f(1));
  assign z = L;
endmodule
