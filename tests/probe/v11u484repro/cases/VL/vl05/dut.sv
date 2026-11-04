// § ownNamedAliasLocalIsRefVar484 (program function local of a program alias of a struct)
program prg;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endprogram
