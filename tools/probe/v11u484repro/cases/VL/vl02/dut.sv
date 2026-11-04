// § ownNamedAliasLocalIsRefVar484 (module function local of a module alias of a module vector typedef)
module top;
  typedef logic [3:0] w_t;
  typedef w_t w2_t;
  function int f(int n);
    w2_t a;
    a = n;
    return a;
  endfunction
  int x;
  initial x = f(1);
endmodule
