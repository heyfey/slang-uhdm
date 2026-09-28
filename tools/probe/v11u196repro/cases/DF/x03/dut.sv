// § dfltArgExecutedRead196v: the defaulted formal read only inside a conditional operator (kept) and in a loop that never runs (folded)
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2);
    return (a > 0) ? a : b;
  endfunction
  function automatic int g(int a, int b = 2);
    int r;
    r = a;
    for (int i = 0; i < 0; i++) r = r + b;
    return r;
  endfunction
  assign o1 = f(1);
  assign o2 = g(5);
endmodule
