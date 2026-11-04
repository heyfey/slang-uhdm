// § cloneHierIdxChainActual482 (three-dimension fixed array)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2][2][2];
    acc[0][1][1].k = n;
    return acc[1][0][1].data;
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
