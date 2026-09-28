// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v: omissions written with named arguments (one omitted, two omitted, reordered full) and an empty positional slot, beside a trailing positional omission
module top(output int o1, output int o2, output int o3, output int o4, output int o5);
  function automatic int f(int a, int b = 2, int c = 9);
    return a + b;
  endfunction
  assign o1 = f(.a(1));
  assign o2 = f(.a(1), .c(3));
  assign o3 = f(.c(3), .b(5), .a(1));
  assign o4 = f(1, , 3);
  assign o5 = f(1);
endmodule
