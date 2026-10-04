// § namedCallArgFormalTs236 — a function declared below its named caller, a task called with named arguments, an implicit net result
module top(input int a, input int b, output int o);
  assign w = f(.q(b), .p(a)) > 0;
  assign o = w ? f(.p(a), .q(1)) : 0;
  always_comb t(.u(a));
  function automatic int f(int p, int q);
    return p * q;
  endfunction
  task automatic t(input int u);
    $display(u);
  endtask
endmodule
