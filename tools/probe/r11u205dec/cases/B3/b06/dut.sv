// r11u205 B3 b06: the omitted formal read in an if condition, omitted by name
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2);
    if (b > 0) return a;
    return a + 7;
  endfunction
  assign o1 = f(.a(1));
  assign o2 = f(.b(1), .a(1));
endmodule
