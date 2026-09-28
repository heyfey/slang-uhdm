// § evalFuncOmittedDefaultKeepsCall196: two defaulted formals (one read, one not), a named-argument call omitting one, an omitted default in a generate-for continuous assignment
module top(output int o1, output int o2, output int o3, output int o4 [2]);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b;
  endfunction
  assign o1 = f(1);
  assign o2 = f(1, 5);
  assign o3 = f(.a(1), .c(4));
  for (genvar i = 0; i < 2; i++) begin : g
    assign o4[i] = f(i);
  end
endmodule
