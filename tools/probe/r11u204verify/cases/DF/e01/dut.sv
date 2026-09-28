// § evalFuncOmittedDefaultKeepsCall196 § dfltArgExecutedRead196v § dfltArgExecutedPathEval196v: a case statement whose taken item returns the supplied formal or the omitted one, and a case whose default item is taken (UHDM ExprEval never runs a default item)
module top(output int o1, output int o2, output int o3);
  function automatic int f(int a, int b = 2);
    case (a)
      0: return b;
      default: return a;
    endcase
  endfunction
  function automatic int g(int a, int b = 7);
    int r;
    case (a)
      1: r = a;
      2: r = b;
      default: r = 0;
    endcase
    return r;
  endfunction
  assign o1 = f(1);
  assign o2 = f(0);
  assign o3 = g(1);
endmodule
