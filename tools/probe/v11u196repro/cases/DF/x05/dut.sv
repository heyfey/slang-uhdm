// § dfltArgExecutedRead196v § dfltArgExecutedPathEval196v: an early return before the read (folded), an overwritten local (folded), a read after a branch (kept)
module top(output int o1, output int o2, output int o3);
  function automatic int f(int a, int b = 2);
    if (a > 0) return a;
    return b;
  endfunction
  function automatic int g(int a, int b = 2);
    int t = b;
    if (a > 0) t = a;
    return t;
  endfunction
  function automatic int h(int a, int b = 2);
    int t;
    t = a;
    if (a > 100) t = 0;
    return t + b;
  endfunction
  assign o1 = f(1);
  assign o2 = g(1);
  assign o3 = h(1);
endmodule
