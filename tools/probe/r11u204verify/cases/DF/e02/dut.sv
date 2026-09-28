// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v § dfltArgExecutedPathEval196v: the omitted formal as a for-loop bound (golden keeps: the loop condition reads it), and a while loop that breaks before the read (fold)
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 3);
    int s = 0;
    for (int i = 0; i < b; i++) s += a;
    return s;
  endfunction
  function automatic int g(int a, int b = 3);
    int s = 0;
    while (1) begin
      if (a > 0) break;
      s = b;
    end
    return a + s;
  endfunction
  assign o1 = f(2);
  assign o2 = g(2);
endmodule
