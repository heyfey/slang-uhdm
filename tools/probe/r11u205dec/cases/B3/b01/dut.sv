// r11u205 B3 b01: omissions by named argument, int return (one, two omitted; a full named call beside)
module top(output int o1, output int o2, output int o3);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b + c;
  endfunction
  assign o1 = f(.a(1));
  assign o2 = f(.a(1), .c(3));
  assign o3 = f(.c(3), .b(5), .a(1));
endmodule
