// § ownNamedAliasLocalIsRefVar484 (uninstantiated module function local of a module alias)
module other;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
endmodule
module top;
  int x;
  initial x = 1;
endmodule
