// § dfltArgExecutedPathEval196v § dfltArgExecutedRead196v: the omitted formal read only in a CONDITION on the executed path (an if condition, a case selector, a while condition, a repeat count), no data path to the result
module top(output int o1, output int o2, output int o3, output int o4);
  function automatic int f(int a, int b = 2);
    if (b > 0) return a;
    return a + 1;
  endfunction
  function automatic int g(int a, int b = 2);
    case (b)
      2: return a;
      default: return a + 1;
    endcase
  endfunction
  function automatic int h(int a, int b = 2);
    int i = 0;
    while (i < b) i++;
    return a;
  endfunction
  function automatic int k(int a, int b = 2);
    int s = a;
    repeat (b) s = s;
    return s;
  endfunction
  assign o1 = f(1);
  assign o2 = g(1);
  assign o3 = h(1);
  assign o4 = k(1);
endmodule
