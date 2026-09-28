// § evalFuncOmittedDefaultKeepsCall196: an omitted defaulted argument the body never reads (the call folds), a named-argument call omitting it, and one passing it by name
module top(output int o1, output int o2, output int o3);
  function automatic int f(int a, int unused = 7); return a * 2; endfunction
  function automatic int h(int a, int b = 4); return a - b; endfunction
  assign o1 = f(3);
  assign o2 = h(.a(9));
  assign o3 = h(.a(9), .b(1));
endmodule
