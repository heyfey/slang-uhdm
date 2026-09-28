// § evalFuncOmittedDefaultKeepsCall196: a call omitting a defaulted argument the body reads is kept; the full call folds; hex and decimal literal actuals fold
module top(output int o1, output int o2, output int o3, output int o4);
  function automatic int f(int a, int b = 2); return a + b; endfunction
  function automatic int g(logic [3:0] a); return a + 1; endfunction
  assign o1 = f(1);
  assign o2 = f(1, 3);
  assign o3 = g(4'h1);
  assign o4 = g(4'd1);
endmodule
