// § dfltArgExecutedRead196v § dfltArgExecutedPathEval196v: the defaulted formal read only in a branch f(1) does not take (golden folds f(1)) and in the else arm f(-1) takes (golden keeps)
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2);
    if (a > 0) return a;
    else return b;
  endfunction
  assign o1 = f(1);
  assign o2 = f(-1);
endmodule
