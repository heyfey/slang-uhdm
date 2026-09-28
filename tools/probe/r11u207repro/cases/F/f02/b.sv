// § namedSlotFillerRootFile207: the second root file of f02
module top(input int i, output int o, output int q);
  function int g(int a, int b = 1, int c = 2); return a * b + c; endfunction
  always_comb o = pa::f(.c(i), .a(1));
  always_comb q = g(.a(i));
endmodule
