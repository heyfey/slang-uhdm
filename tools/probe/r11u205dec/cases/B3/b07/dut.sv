// r11u205 B3 b07: mixed positional and named, the middle formal omitted
module top(output int o1);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b + c;
  endfunction
  assign o1 = f(1, .c(3));
endmodule
