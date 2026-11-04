// § cloneHierIdxChainActual482 (queue of fixed arrays acc[$][2])
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[$][2];
    op_t e[2];
    acc.push_back(e);
    acc[0][1].k = n;
    return acc[0][1].data;
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
