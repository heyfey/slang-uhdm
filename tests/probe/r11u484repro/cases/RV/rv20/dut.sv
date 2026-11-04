// § ownNamedAliasLocalIsRefVar484 (negative: a package alias shadowed by an imported same-named typedef)
package q;
  typedef struct { int k; int d; } op2_t;
endpackage
package u;
  import q::*;
  typedef struct { int k; int data; } op_t;
  typedef op_t op3_t;
  function int f(int n);
    op3_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
