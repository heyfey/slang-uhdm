// § cloneFixArrAggElemShared482 (home alias of a struct from a third package s)
package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  import s::*;
  typedef s::op_t op_t2;
  function int f(int n);
    op_t2 acc[2];
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
