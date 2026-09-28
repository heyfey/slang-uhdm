// § evalFuncOmittedDefaultKeepsCall196: two defaulted formals, the read one supplied and the unread one omitted; and the read one omitted beside a supplied unread one
module top(output int o1, output int o2);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b;
  endfunction
  assign o1 = f(1, 5);
  assign o2 = f(1);
endmodule
