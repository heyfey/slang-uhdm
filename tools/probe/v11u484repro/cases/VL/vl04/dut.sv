// § ownNamedAliasLocalIsRefVar484 (package local with an initializer)
package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a = '{k: 1, d: 2};
    a.k = n;
    return a.d;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
