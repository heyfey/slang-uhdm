// § ownNamedAliasLocalIsRefVar484 (module function local of a module alias of a $unit struct)
typedef struct { int k; int d; } op_t;
module top;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endmodule
