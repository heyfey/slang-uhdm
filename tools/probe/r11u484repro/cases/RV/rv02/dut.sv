// § ownNamedAliasLocalIsRefVar484 (module function local of a module alias of a struct)
module top;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
  int x;
  initial x = f(1);
endmodule
