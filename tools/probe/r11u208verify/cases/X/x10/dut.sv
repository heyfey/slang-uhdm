// § sysCtxRefArgBare201 § dfltArgTaintExec204v § evalFuncOmittedDefaultKeepsCall196
module x10 (input logic [3:0] a, output int o1, output int o2, output int o3, output int o4, output int o5);
  localparam int P = 3;
  function automatic int f(int x, int b = 2);
    if (b > 0) return x;
    return x + 1;
  endfunction
  function automatic int g(int x, int b = 2);
    return x + b;
  endfunction
  assign o1 = f(P);
  assign o2 = g(P);
  assign o3 = $countones(f(a));
  assign o4 = $countones(g(a));
  assign o5 = g($countones(4'(P)));
endmodule
