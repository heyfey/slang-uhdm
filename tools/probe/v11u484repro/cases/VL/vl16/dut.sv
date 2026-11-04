// § ownNamedAliasLocalIsRefVar484 (two declarators with an initializer on the first)
module top;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a = '{1, 2}, b;
    b = a;
    b.k = n;
    return b.k + a.d;
  endfunction
  int x;
  initial x = f(1);
endmodule
