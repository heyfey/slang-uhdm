// r11u205 B3 b08: unsigned formals and return, named omission
module top(output int unsigned o1, output int unsigned o2);
  function automatic int unsigned f(int unsigned a, int unsigned b = 5);
    return a + b;
  endfunction
  assign o1 = f(.a(1));
  assign o2 = f(1, 4);
endmodule
