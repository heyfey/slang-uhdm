// § cloneAliasCopyBareName484 (alias declared in the importing package of the home struct, local in a function cloned again into a third package)
package u;
  typedef struct { int k; int data; } op_t;
endpackage
package a;
  import u::*;
  typedef op_t op2_t;
  function int g(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package b;
  import a::*;
  function int h(); return g(2); endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = h();
endmodule
