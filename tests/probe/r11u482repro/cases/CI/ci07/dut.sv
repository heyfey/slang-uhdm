// § cloneFixArrAggElemShared482 (two importing packages)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
package b;
  import u::*;
  function int h(); return f(2); endfunction
endpackage
module top;
  import a::*;
  import b::*;
  int x;
  initial x = g() + h();
endmodule
