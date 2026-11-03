// § parenCallCallee479
function automatic int ff(int a, int b = 4); return a + b; endfunction
module top(output int z);
  initial z = (ff(3));
endmodule
