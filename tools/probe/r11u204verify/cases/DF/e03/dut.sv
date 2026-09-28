// § evalFuncOmittedDefaultKeepsCall196: nested calls (an omitted-default call as another call's argument, a full call inside an omitted one), a body calling a defaulted function with the default omitted, a non-whole Rhs
module top(output int o1, output int o2, output int o3, output int o4);
  function automatic int f(int a, int b = 2); return a + b; endfunction
  function automatic int g(int a); return a * 2; endfunction
  function automatic int h(int a); return f(a); endfunction
  assign o1 = g(f(1));
  assign o2 = f(f(1, 2));
  assign o3 = h(1);
  assign o4 = f(1) + 1;
endmodule
