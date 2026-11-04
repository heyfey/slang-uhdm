// § cloneAliasCopyBareName484 (middle alias in the home package over a third-package struct, cloned)
package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  typedef s::op_t mid_t;
  typedef mid_t op2_t;
  function int f(int n);
    op2_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
