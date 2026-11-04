// § ownNamedAliasLocalIsRefVar484 (var keyword and a static local of the alias)
package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    var op2_t a;
    static op2_t b;
    a.k = n; b = a;
    return b.k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
