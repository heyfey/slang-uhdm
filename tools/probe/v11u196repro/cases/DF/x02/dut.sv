// § dfltArgExecutedRead196v: a defaulted formal read through a local assigned from it, a default written as a parameter, a call in a generate loop (kept)
module top #(parameter int K = 3) (output int o1, output int o2 [2]);
  function automatic int f(int a, int b = K);
    int t;
    t = b;
    return a + t;
  endfunction
  assign o1 = f(1);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o2[i] = f(i);
  end
endmodule
