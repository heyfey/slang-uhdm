// r11u205 B3 b05: a nested call, the inner one omitting by name
module top(output int o1);
  function automatic int f(int a, int b = 2);
    return a + b;
  endfunction
  function automatic int g(int x);
    return x * 3;
  endfunction
  assign o1 = g(f(.a(1)));
endmodule
