// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v: later assignments overwriting the unset value (fold), an assignment in a branch not taken (fold), a read carried through a local (keep: moved to e04b)
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2);
    int r;
    r = b;
    r = a;
    return r;
  endfunction
  function automatic int g(int a, int b = 2);
    int r;
    r = a;
    if (a > 5) r = b;
    return r;
  endfunction
  assign o1 = f(1);
  assign o2 = g(1);
endmodule
