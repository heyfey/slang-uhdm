// § ownNamedAliasLocalIsRefVar484 (module alias of a module typedef of an int (keyword base))
module top;
  typedef int i_t;
  typedef i_t i2_t;
  function int f(int n);
    i2_t a;
    a = n + 1;
    return a;
  endfunction
  int x;
  initial x = f(1);
endmodule
