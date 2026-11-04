// § cloneAliasCopyBareName484 (home alias local in a clone reached through an explicit import of the function and of the alias)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::f;
  import u::op2_t;
  function int g(); op2_t m; m.k = 1; return f(m.k); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
