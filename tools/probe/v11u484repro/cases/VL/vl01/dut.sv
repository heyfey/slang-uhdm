// § ownNamedAliasLocalIsRefVar484 (package local of an alias of an alias of a struct)
package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
  function int f(int n);
    op3_t a;
    a.k = n;
    return a.k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
