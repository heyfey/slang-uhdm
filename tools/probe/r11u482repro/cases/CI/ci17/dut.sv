// § cloneFixArrAggElemShared482 (foreach over the fixed array)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[3];
    int r;
    r = 0;
    foreach (acc[i]) r += acc[i].data;
    return r + n;
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
