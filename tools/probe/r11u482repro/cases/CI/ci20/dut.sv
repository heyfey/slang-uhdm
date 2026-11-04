// § cloneFixArrAggElemShared482 (two functions sharing the struct)
package u;
  typedef struct { int k; int data; } op_t;
  function int f2(int n);
    op_t q[2];
    q[1].data = n;
    return q[1].k;
  endfunction
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[1].data + f2(n);
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
