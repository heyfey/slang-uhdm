// § cloneArrElemAggOwnCopy482 (queue of a struct with an anonymous struct member)
package u;
  typedef struct { struct { int q; } in; int data; } op_t;
  function int f(int n);
    op_t acc[$];
    op_t e;
    e.data = n;
    acc.push_back(e);
    return acc[0].data;
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
