// § caOpArgIntFormalTs236 — operation actuals reading an implicit net and a variable written in a process
module top (input int a, output int o, output int o2);
  function automatic int f(int x);
    return x;
  endfunction
  int r;
  always_comb r = a;
  assign w = a[0];
  assign o = f(w + 1);
  assign o2 = f(r - 1);
endmodule
