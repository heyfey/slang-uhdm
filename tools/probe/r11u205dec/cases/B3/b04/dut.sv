// r11u205 B3 b04: a default that reads another formal, omitted by name
module top(output int o1);
  function automatic int f(int a, int b = a);
    return a * 2 + b;
  endfunction
  assign o1 = f(.a(3));
endmodule
