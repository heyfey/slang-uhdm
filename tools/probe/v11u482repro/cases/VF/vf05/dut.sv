// § cloneFixArrAggElemShared482 (parameter-sized array)
package u;
  parameter N = 3;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[N];
    acc[0].k = n;
    return acc[N-1].data;
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
