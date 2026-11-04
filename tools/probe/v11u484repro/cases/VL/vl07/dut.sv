// § ownNamedAliasLocalIsRefVar484 (module alias in a parameterized module instantiated twice)
module sub #(parameter int W = 4) (output int o);
  typedef logic [W-1:0] w_t;
  typedef w_t w2_t;
  function int f(int n);
    w2_t a;
    a = n;
    return a;
  endfunction
  assign o = f(3);
endmodule
module top;
  int a, b;
  sub #(4) u1(a);
  sub #(8) u2(b);
endmodule
