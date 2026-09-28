// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v § dfltArgExecutedPathEval196v: defaults written from a module parameter and a sized hex literal, read in a taken and a not-taken branch; a string default (non-integral)
module top #(parameter int P = 5) (output int o1, output int o2, output logic [3:0] o3, output int o4);
  function automatic int f(int a, int b = P);
    if (a > 0) return a + b;
    return a;
  endfunction
  function automatic logic [3:0] g(logic [3:0] a, logic [3:0] m = 4'hF);
    if (a == 0) return m;
    return a;
  endfunction
  function automatic int s(int a, string t = "x");
    return a + t.len();
  endfunction
  assign o1 = f(1);
  assign o2 = f(-1);
  assign o3 = g(4'd3);
  assign o4 = s(1);
endmodule
