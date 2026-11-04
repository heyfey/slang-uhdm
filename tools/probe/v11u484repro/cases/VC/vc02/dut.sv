// § cloneAliasCopyBareName484 (middle alias in another package (u alias of s alias of s struct))
package s;
  typedef struct { int k; int data; } op_t;
  typedef op_t mid_t;
endpackage
package u;
  import s::*;
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
