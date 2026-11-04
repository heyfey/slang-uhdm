// § ownNamedAliasLocalIsRefVar484 (two locals in one declaration plus a dynamic array of the alias)
package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a, b;
    op2_t q[$];
    a.k = n; b = a;
    q.push_back(b);
    return q[0].k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
