// § cloneAliasCopyBareName484 (two packages each with an alias named op2_t, both cloned)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package v;
  typedef struct { int z; } op_t;
  typedef op_t op2_t;
  function int h(int n);
    op2_t acc;
    acc.z = n;
    return acc.z;
  endfunction
endpackage
package a;
  import u::*;
  import v::h;
  function int g(); return f(1) + h(2); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
