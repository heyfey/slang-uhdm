// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v: later assignments overwriting the unset value (fold), an assignment in a branch not taken (fold), a read carried through a local (keep)
module top(output int o3);
  function automatic int h(int a, int b = 2);
    int r;
    r = b + 0;
    r = r - b + a;
    return r;
  endfunction
  assign o3 = h(1);
endmodule
