// § evalFuncOmittedDefaultKeepsCall196: an empty positional slot for a defaulted middle argument
module top(output int o1);
  function automatic int f(int a, int b = 5, int c = 1); return a + b + c; endfunction
  assign o1 = f(1, , 2);
endmodule
