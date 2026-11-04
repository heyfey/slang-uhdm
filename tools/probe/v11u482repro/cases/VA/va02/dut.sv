// § cloneArrElemAggOwnCopy482 (queue of a union)
package u;
  typedef union { int i; bit [31:0] b; } op_t;
  function int f(int n);
    op_t acc[$];
    op_t e;
    e.i = n;
    acc.push_back(e);
    return acc[0].i;
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
