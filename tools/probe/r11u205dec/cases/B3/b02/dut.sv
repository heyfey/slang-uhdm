// r11u205 B3 b02: an empty positional slot, and a trailing positional omission beside it
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b + c;
  endfunction
  assign o1 = f(1, , 3);
  assign o2 = f(1);
endmodule
