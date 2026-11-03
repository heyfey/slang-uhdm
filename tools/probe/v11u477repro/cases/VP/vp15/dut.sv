// § parenCallWrittenArgs477
module top(output int z[2]);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    initial z[i] = (f(i));
  end
endmodule
