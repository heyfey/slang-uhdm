// § forMultiInitAssign258 (two initializers in a module function)
module m; int y;
  function automatic int f(int a);
    int i, j, n;
    for (i = 0, j = a; i < 4; i++) n += j;
    return n;
  endfunction
  always_comb y = f(3);
endmodule
module top; m u(); endmodule
