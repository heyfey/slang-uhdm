// § cloneAliasCopyBareName484 (scalar local of a home alias of a third-package struct)
package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  import s::*;
  typedef s::op_t op_t2;
  function int f(int n);
    op_t2 acc;
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
