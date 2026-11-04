// § cloneFixArrAggElemShared482 (fixed array plus a scalar of the struct)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    op_t one;
    one.k = n;
    acc[0] = one;
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
