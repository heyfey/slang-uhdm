// § cloneAliasCopyBareName484 (four-level alias chain local in an import clone)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
  typedef op3_t op4_t;
  function int f(int n);
    op4_t acc;
    acc.k = n;
    return acc.data;
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
